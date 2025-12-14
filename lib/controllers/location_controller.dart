import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/repository/location_repository.dart';
import '../models/location_models.dart';

class LocationController extends GetxController {
  final LocationRepository _repository;
  LocationController({required LocationRepository repository})
      : _repository = repository;

  // State
  final Rx<CachedLocationData?> cachedLocation = Rx<CachedLocationData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasLocation = false.obs;
  final RxString error = ''.obs;

  // Addresses state
  final RxList<CustomerAddress> addresses = <CustomerAddress>[].obs;
  final RxBool isLoadingAddresses = false.obs;
  final RxBool isMutatingAddress = false.obs;
  final RxString localDefaultAddressId = ''.obs;

  // Carried canonical location id
  final RxString selectedLocationId = ''.obs;

  // Serviceability UX
  final Rx<ServiceLocation?> resolvedService = Rx<ServiceLocation?>(null);
  final RxBool areaNotServiceable = false.obs;
  final RxList<ServiceLocation> serviceableList = <ServiceLocation>[].obs;

  // Single-shot submit guard
  final RxBool _submitting = false.obs;

  // Tokens carried from Confirm
  final RxString resolvedPin = ''.obs;
  final RxString resolvedCity = ''.obs;
  final RxString resolvedState = ''.obs;
  final RxString resolvedSubLocality = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _startupSequence();
  }

  Future<void> _startupSequence() async {
    // 1. Try to load from local storage first (Fastest)
    await _loadCachedLocation();
    await _loadLocalDefault();

    // 2. CRITICAL FIX: If local storage is empty (Fresh Install), 
    // immediately fetch from Server API.
    if (!hasLocation.value) {
      // 'silent: true' updates the state without a full-screen loader
      await fetchCustomerAddresses(silent: true);
    }

    _warmServiceableCache();
  }

  Future<void> _warmServiceableCache() async {
    try {
      final list = await _repository.fetchServiceableLocations();
      serviceableList.assignAll(list);
    } catch (_) {}
  }

  Future<void> _loadLocalDefault() async {
    final id = await _repository.getLocalDefaultAddressId();
    if (id != null && id.isNotEmpty) {
      localDefaultAddressId.value = id;
    }
  }

  Future<void> _loadCachedLocation() async {
    try {
      final location = await _repository.getCachedLocation();
      cachedLocation.value = location;
      hasLocation.value = location != null;
    } catch (_) {}
  }

  // =========== POST ONLY ON MAP DETAIL ===========
  Future<bool> saveLocation({
    required LatLng coordinates,
    required String address,
    required String label,
    required String locationId,
    String? houseNumber,
    String? landmark,
  }) async {
    if (_submitting.value) return false;
    _submitting.value = true;

    try {
      isLoading.value = true;
      error.value = '';

      // Ensure resolved PIN exists; never proceed with empty PIN in strict policy
      final pin = resolvedPin.value.trim();
      final city = resolvedCity.value.trim();
      final state = resolvedState.value.trim();

      // Debug: show overrides used for save
      // ignore: avoid_print
      print('🛟 Save overrides -> pin:"$pin" city:"$city" state:"$state" '
          'locId:"$locationId" addr:"$address"');

      if (pin.isEmpty || pin.length != 6) {
        error.value = 'PIN missing or invalid. Please confirm location again.';
        // ignore: avoid_print
        print('⛔ Aborting save: missing/invalid PIN for strict PIN-only flow');
        return false;
      }

      // (Optional) sanity: avoid passing PIN as state accidentally
      String? safeState;
      if (state.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(state)) {
        safeState = state;
      }

      final response = await _repository.saveLocation(
        latitude: coordinates.latitude.toString(),
        longitude: coordinates.longitude.toString(),
        address: address,
        label: label,
        houseNumber: houseNumber,
        landmark: landmark,
        locationId: locationId,
        // Forward overrides so repo does not re-derive a different PIN
        overrideCity: city.isNotEmpty ? city : null,
        overrideState: safeState,
        overridePostCode: pin,
      );

      if (response.success) {
        selectedLocationId.value =
            (response.locationId != null && response.locationId!.isNotEmpty)
                ? response.locationId!
                : locationId;

        await _loadCachedLocation();
        await fetchCustomerAddresses(silent: true);
        return true;
      } else {
        error.value = response.message;
        // ignore: avoid_print
        print('⚠️ Save failed from backend: ${response.message}');
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      await _loadCachedLocation();
      return hasLocation.value;
    } finally {
      isLoading.value = false;
      _submitting.value = false;
    }
  }

  // Confirm button — strictly PIN-first
  // Carry locationId and resolved tokens; DO NOT POST
  Future<bool> resolveForNavigation({
    required LatLng coordinates,
    required String uiLocationTitle, // e.g., "Indira Nagar, Lucknow"
    required String uiLocationDetails, // optional
    required String composedAddress, // "$title, $details"
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      areaNotServiceable.value = false;
      resolvedService.value = null;

      // Parse visible strings to extract PIN and locality for resolution
      final parts = _parseAddressFromString(composedAddress);
      final extractedPin =
          _extractPostCode(composedAddress) ?? parts['postCode'] ?? '';
      final subLocality =
          _extractPrimaryToken(uiLocationTitle) ?? _extractPrimaryToken(composedAddress);

      // Use parsed city/state so they don't get swapped
      final parsedCity = parts['city'] ?? '';
      final parsedState = parts['state'] ?? '';

      // Debug: show extracted values prior to resolution
      // ignore: avoid_print
      print('🧭 Confirm extracted -> pin:"$extractedPin" sub:"${subLocality ?? ''}" '
          'city:"$parsedCity" state:"$parsedState"');

      // Hard-require a PIN for strict policy
      if (extractedPin.trim().isEmpty || extractedPin.trim().length != 6) {
        error.value = 'Please select a location with a valid 6-digit PIN.';
        areaNotServiceable.value = true;
        // ignore: avoid_print
        print('⛔ Confirm blocked: no valid PIN found in composedAddress');
        return false;
      }

      if (serviceableList.isEmpty) {
        final list = await _repository.fetchServiceableLocations();
        serviceableList.assignAll(list);
      }

      final svc = await _repository.resolveServiceLocation(
        postCode: extractedPin.trim(),
        locality: parsedCity,
        subLocality: subLocality,
      );

      if (svc == null) {
        error.value = 'Out of coverage';
        areaNotServiceable.value = true;
        // ignore: avoid_print
        print('🚫 Confirm failed: no service row for PIN "${extractedPin.trim()}"');
        return false;
      }

      // Persist selected id and resolved tokens for save step
      resolvedService.value = svc;
      selectedLocationId.value = svc.id;
      resolvedPin.value = extractedPin.trim();
      resolvedCity.value = parsedCity.trim();
      resolvedState.value = parsedState.trim();
      resolvedSubLocality.value = (subLocality ?? '').trim();

      // Debug: selected service row
      // ignore: avoid_print
      print('✅ Confirm OK -> locId:"${svc.id}" pin:"${resolvedPin.value}" '
          'city:"${resolvedCity.value}" state:"${resolvedState.value}"');

      return true;
    } catch (e) {
      error.value = e.toString();
      // ignore: avoid_print
      print('❌ Confirm exception: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Optional compatibility path: now strictly requires a PIN; no address parsing fallback to 000000.
  Future<bool> saveLocationValidated({
    required LatLng coordinates,
    required String address,
    required String label,
    String? houseNumber,
    String? landmark,
    String? uiLocationTitle,
    String? uiLocationDetails,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      areaNotServiceable.value = false;
      resolvedService.value = null;

      // Strict policy: prefer confirmed tokens; do not derive a placeholder PIN from address text
      final confirmedPin = resolvedPin.value.trim();
      final confirmedCity = resolvedCity.value.trim();
      final confirmedState = resolvedState.value.trim();
      final confirmedSub = resolvedSubLocality.value.trim();

      // Debug: show tokens for validated-save path
      // ignore: avoid_print
      print('🧭 Validated path using confirmed -> pin:"$confirmedPin" sub:"$confirmedSub" '
          'city:"$confirmedCity" state:"$confirmedState"');

      if (confirmedPin.isEmpty || confirmedPin.length != 6) {
        error.value = 'Please confirm a location with a valid 6-digit PIN.';
        areaNotServiceable.value = true;
        // ignore: avoid_print
        print('⛔ Validated path blocked: missing/invalid confirmed PIN');
        return false;
      }

      if (serviceableList.isEmpty) {
        final list = await _repository.fetchServiceableLocations();
        serviceableList.assignAll(list);
      }

      final svc = await _repository.resolveServiceLocation(
        postCode: confirmedPin,
        locality: confirmedCity.isNotEmpty ? confirmedCity : null,
        subLocality: confirmedSub.isNotEmpty ? confirmedSub : null,
      );

      if (svc == null) {
        areaNotServiceable.value = true;
        // ignore: avoid_print
        print('🚫 Validated path: no service row for confirmed PIN "$confirmedPin"');
        return false;
      }

      resolvedService.value = svc;
      selectedLocationId.value = svc.id;

      // Proceed to save with overrides so we don’t re-derive PIN
      return await saveLocation(
        coordinates: coordinates,
        address: address,
        label: label,
        locationId: svc.id,
        houseNumber: houseNumber,
        landmark: landmark,
      );
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkLocationExists() async {
    final exists = await _repository.hasLocationCached();
    hasLocation.value = exists;
    return exists;
  }

  Future<void> clearLocation() async {
    try {
      await _repository.clearLocationCache();
      cachedLocation.value = null;
      hasLocation.value = false;
      selectedLocationId.value = '';
      resolvedService.value = null;
      areaNotServiceable.value = false;
      resolvedPin.value = '';
      resolvedCity.value = '';
      resolvedState.value = '';
      resolvedSubLocality.value = '';
    } catch (e) {
      error.value = e.toString();
    }
  }

  String getLocationSummary() {
    if (cachedLocation.value == null) return 'No location set';
    final l = cachedLocation.value!;
    return '${l.label} - ${l.address.split(',').first}';
  }

  String? getFullAddress() => cachedLocation.value?.address;

  Future<void> fetchCustomerAddresses({bool silent = false}) async {
    try {
      if (!silent) isLoadingAddresses.value = true;
      error.value = '';

      final fetched = await _repository.getCustomerAddresses();

      final localId = localDefaultAddressId.value;
      CustomerAddress markDefault(CustomerAddress a) => a.copyWith(
            isDefault: a.isDefault || (localId.isNotEmpty && a.id == localId),
          );

      final list = fetched.map((a) => markDefault(a)).toList();
      addresses.value = list;

      CustomerAddress? def;
      for (final a in list) {
        if (a.isDefault) {
          def = a;
          break;
        }
      }

      if (def != null) {
        final composed =
            '${def.addressLine1}, ${def.addressLine2}, ${def.city}, ${def.state} - ${def.postCode}';
        final prev = cachedLocation.value?.address ?? '';

        if ((def.locationId ?? '').isNotEmpty) {
          selectedLocationId.value = def.locationId!;
        }

        if (prev != composed) {
          _syncCachedFromAddress(def);
          final cl = cachedLocation.value!;
          await _repository.persistActiveLocation(cl);
          await _repository.saveCachedLocationJson(cl);
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      if (!silent) isLoadingAddresses.value = false;
    }
  }

  Future<void> setDefaultAddressLocal(String addressId) async {
    try {
      isMutatingAddress.value = true;

      addresses.value =
          addresses.map((a) => a.copyWith(isDefault: a.id == addressId)).toList();
      localDefaultAddressId.value = addressId;
      await _repository.saveLocalDefaultAddressId(addressId);

      CustomerAddress? selected;
      for (final a in addresses) {
        if (a.id == addressId) {
          selected = a;
          break;
        }
      }

      if (selected != null) {
        if ((selected.locationId ?? '').isNotEmpty) {
          selectedLocationId.value = selected.locationId!;
        } else {
          selectedLocationId.value = '';
        }

        _syncCachedFromAddress(selected);
        final cl = cachedLocation.value!;
        await _repository.persistActiveLocation(cl);
        await _repository.saveCachedLocationJson(cl);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isMutatingAddress.value = false;
    }
  }
  Future<bool> deleteAddress(String addressId) async {
    try {
      isMutatingAddress.value = true;
      error.value = '';

      // 1. Call Repository
      final success = await _repository.deleteCustomerAddress(addressId);

      if (success) {
        // 2. Optimistic Update: Remove from UI immediately
        addresses.removeWhere((item) => item.id == addressId);

        // 3. Cleanup: If user deleted their "Default" address, clear that preference
        if (localDefaultAddressId.value == addressId) {
          print('⚠️ Deleted local default address; resetting preference.');
          localDefaultAddressId.value = '';
          await _repository.saveLocalDefaultAddressId('');
          
          // Optional: Clear home screen location if it matches the deleted one
          if (selectedLocationId.value == addressId) {
             await clearLocation();
          }
        }
        return true;
      } else {
        error.value = 'Failed to delete address';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isMutatingAddress.value = false;
    }
  }

  void _syncCachedFromAddress(CustomerAddress a) {
    cachedLocation.value = CachedLocationData(
      label: a.label ?? 'HOME',
      address:
          '${a.addressLine1}, ${a.addressLine2}, ${a.city}, ${a.state} - ${a.postCode}',
      latitude: double.tryParse(a.latitude ?? '') ?? 0.0,
      longitude: double.tryParse(a.longitude ?? '') ?? 0.0,
      houseNumber: a.addressLine1,
      landmark: a.addressLine2,
      city: a.city,
      state: a.state,
      postCode: a.postCode,
      savedAt: DateTime.now(),
    );
    hasLocation.value = true;
  }

  // Helpers: light parsing from strings (no geocoding import here)
  Map<String, String?> _parseAddressFromString(String address) {
    final parts = address.split(',').map((e) => e.trim()).toList();

    // For "SubLocality, City, State, PIN"
    // city = second last non-PIN part, state = third last non-PIN part (if present)
    String? city;
    String? state;

    if (parts.length >= 3) {
      city = parts[parts.length - 3];
      state = parts[parts.length - 2];
    } else if (parts.length == 2) {
      city = parts[0];
      state = parts[1];
    } else if (parts.isNotEmpty) {
      city = parts.last;
    }

    final post = _extractPostCode(address);
    return {
      'city': city ?? 'Unknown',
      'state': state ?? 'Unknown',
      'postCode': post ?? '000000',
    };
  }

  String? _extractPostCode(String text) {
    final reg = RegExp(r'(\d{3}\s?\d{3})');
    final m = reg.firstMatch(text);
    if (m == null) return null;
    return m.group(1)?.replaceAll(' ', '');
  }

  String? _extractPrimaryToken(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final t = text.split(',').first.trim();
    return t.isEmpty ? null : t;
  }
}
