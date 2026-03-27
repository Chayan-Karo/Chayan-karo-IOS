import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import '../../data/local/database.dart';
import '../../data/remote/api_service.dart';
import '../../models/location_models.dart';

class LocationRepository {
  final ApiService _apiService;
  final AppDatabase _database;

  LocationRepository({
    required ApiService apiService,
    required AppDatabase database,
  })  : _apiService = apiService,
        _database = database;

  // ===== Serviceable locations cache =====
  List<ServiceLocation> _serviceableCache = [];

  Future<List<ServiceLocation>> fetchServiceableLocations() async {
    if (_serviceableCache.isNotEmpty) {
      // Debug
      // ignore: avoid_print
      print('🧊 Serviceable cache hit: ${_serviceableCache.length} rows');
      return _serviceableCache;
    }
    final token = await _database.getAuthToken();
    if (token == null) throw Exception('User not authenticated');
    final resp = await _apiService.getServiceableLocations('Bearer $token');
    _serviceableCache = resp.result;
    // Debug
    // ignore: avoid_print
    print('🔥 Serviceable cache warm: ${_serviceableCache.length} rows');
    return _serviceableCache;
  }

  // ===== Helpers =====

  // Build addressLine2 so:
  // - backend requirement "address line2 is required" is satisfied
  // - PIN (postCode) is NOT duplicated inside this line.
  String _buildAddressLine2({
    required String baseAddress,
    String? landmark,
    String? postCode,
  }) {
    // 1) Prefer explicit landmark (user input)
    if (landmark != null && landmark.trim().isNotEmpty) {
      return landmark.trim();
    }

    var cleaned = baseAddress;

    // 2) Strip explicit postCode (6 digits) if present in baseAddress
    if (postCode != null && postCode.trim().isNotEmpty) {
      final compactPin = postCode.replaceAll(' ', '');
      cleaned = cleaned
          .replaceAll(compactPin, '')
          .replaceAll(postCode, '')
          .trim();
    }

    // 3) Generic 6‑digit cleanup, in case geocoder formatted differently
    cleaned = cleaned.replaceAll(RegExp(r'\d{6}'), '').trim();

    // 4) Clean up redundant commas/spaces
    cleaned = cleaned
        .replaceAll(RegExp(r'\s+,'), ',')
        .replaceAll(RegExp(r',\s*,+'), ',')
        .trim();

    // 5) Backend requires this field non‑empty
    if (cleaned.isEmpty) {
      return 'N/A';
    }

    return cleaned;
  }

  // ===== Service location resolution =====
  // Strict PIN-first: if PIN present, match by PIN only; do NOT check names in this scenario.
  // Only when no PIN candidates exist, try name-only over rows with no PIN.
  Future<ServiceLocation?> resolveServiceLocation({
    required String postCode,
    String? locality, // city/locality (e.g., Lucknow)
    String? subLocality, // area/colony (e.g., Indira Nagar)
  }) async {
    final list = await fetchServiceableLocations();

    String normPin(String? s) => (s ?? '').replaceAll(' ', '').toLowerCase();
    String normText(String? s) => (s ?? '').trim().toLowerCase();

    final pc = normPin(postCode);
    final sub = normText(subLocality);
    final loc = normText(locality);

    // Debug inputs
    // ignore: avoid_print
    print(
        '✅ resolveServiceLocation() inputs -> PIN:$pc raw:"$postCode" sub:"$sub" city:"$loc"');

    // 1) Exact PIN shortlist and return immediately (no name checks when PIN exists)
    if (pc.isNotEmpty) {
      for (final e in list) {
        final epc = normPin(e.postCode);
        if (epc.isNotEmpty && epc == pc) {
          // ignore: avoid_print
          print(
              '🎯 PIN matched entry -> id:${e.id} area:"${e.areaName}" pin:"${e.postCode}"');
          return e;
        }
      }
      // ignore: avoid_print
      print(
          '⚠️ No row found with PIN:$pc; will try name-only fallback (rows without PIN)');
    }

    // 2) Name-only fallback across rows without PIN
    if (sub.isNotEmpty || loc.isNotEmpty) {
      final tokens = <String>{sub, loc}.where((t) => t.isNotEmpty).toList();
      for (final e in list) {
        final epc = normPin(e.postCode);
        if (epc.isNotEmpty) continue; // skip rows that actually have a PIN
        final name = normText(e.areaName);
        if (name.isEmpty) continue;
        for (final t in tokens) {
          if (name.contains(t) || t.contains(name)) {
            // ignore: avoid_print
            print(
                '🔎 Name-only fallback matched -> id:${e.id} area:"${e.areaName}" (no PIN on row)');
            return e;
          }
        }
      }
      // ignore: avoid_print
      print('🚫 Name-only fallback failed for tokens:$tokens');
    } else {
      // ignore: avoid_print
      print('🚫 No tokens provided and PIN empty; cannot resolve');
    }

    return null;
  }

  // ===== Save via API + local cache =====
  Future<AddAddressResponse> saveLocation({
    required String latitude,
    required String longitude,
    required String address,
    required String label,
    required String locationId,
    String? houseNumber,
    String? landmark,

    // allow controller to override city/state/postCode (use same PIN as Confirm)
    String? overrideCity,
    String? overrideState,
    String? overridePostCode,
  }) async {
    try {
      final token = await _database.getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Reverse geocode only as a fallback if overrides are missing
      Map<String, String?> parsed = const {
        'city': null,
        'state': null,
        'postCode': null,
      };
      final needReverse =
          (overrideCity == null || overrideCity.trim().isEmpty) ||
              (overrideState == null || overrideState.trim().isEmpty) ||
              (overridePostCode == null || overridePostCode.trim().isNotEmpty == false);

      if (needReverse) {
        // ignore: avoid_print
        print(
            'ℹ️ Overrides incomplete; reverse-geocoding as fallback for city/state/PIN');
        parsed = await _parseAddress(
          double.parse(latitude),
          double.parse(longitude),
          address,
        );
        // ignore: avoid_print
        print(
            '🗺️ Reverse geocode parsed -> city:${parsed['city']} state:${parsed['state']} pin:${parsed['postCode']}');
      } else {
        // ignore: avoid_print
        print('✅ Using overrides from controller; skipping reverse-geocoding');
      }

      final city = (overrideCity != null && overrideCity.trim().isNotEmpty)
          ? overrideCity
          : (parsed['city'] ?? 'N/A');
      final state = (overrideState != null && overrideState.trim().isNotEmpty)
          ? overrideState
          : (parsed['state'] ?? 'N/A');
      final postCode =
          (overridePostCode != null && overridePostCode.trim().isNotEmpty)
              ? overridePostCode
              : (parsed['postCode'] ?? '000000');

      // Debug final payload being sent
      // ignore: avoid_print
      print('📦 AddAddressRequest -> '
          'locId:$locationId city:"$city" state:"$state" pin:"$postCode" '
          'lat:$latitude long:$longitude label:"$label" addr:"$address"');

      final request = AddAddressRequest(
        locationId: locationId,
        addressLine1: houseNumber ?? 'N/A',
        // ensure non-empty, and strip PIN out of text
        addressLine2: _buildAddressLine2(
          baseAddress: address,
          landmark: landmark,
          postCode: postCode,
        ),
        city: city,
        state: state,
        postCode: postCode,
        lat: double.parse(latitude),
        long: double.parse(longitude),
        addressType: label,
      );

      final response =
          await _apiService.addCustomerAddress('Bearer $token', request);

      // Debug response summary
      // ignore: avoid_print
      print('✅ addCustomerAddress success:${response.success} '
          'locationId:"${response.locationId ?? ''}" '
          'message:"${response.message}"');

      await _cacheLocation(
        label: label,
        address: address,
        latitude: double.parse(latitude),
        longitude: double.parse(longitude),
        houseNumber: houseNumber,
        landmark: landmark,
        city: city,
        state: state,
        postCode: postCode,
        addressType: label,
      );

      return response;
    } catch (e) {
      // ignore: avoid_print
      print('❌ saveLocation error: $e');
      try {
        await _cacheLocation(
          label: label,
          address: address,
          latitude: double.parse(latitude),
          longitude: double.parse(longitude),
          houseNumber: houseNumber,
          landmark: landmark,
        );
      } catch (_) {}
      rethrow;
    }
  }

  // ===== Client-only default persistence =====
  Future<void> saveLocalDefaultAddressId(String id) async {
    await _database.saveUserPreference('default_address_id', id);
    // ignore: avoid_print
    print('💾 Saved local default addressId:$id');
  }

  Future<String?> getLocalDefaultAddressId() async {
    final v = await _database.getUserPreference('default_address_id');
    // ignore: avoid_print
    print('🔎 Read local default addressId:"${v ?? ''}"');
    return v;
  }

  Future<void> saveCachedLocationJson(CachedLocationData data) async {
    await _database.saveUserPreference(
        'location_json', jsonEncode(data.toJson()));
    // ignore: avoid_print
    print('💾 Saved cached location JSON at ${data.savedAt.toIso8601String()}');
  }

  Future<void> persistActiveLocation(CachedLocationData data) async {
    await _database.saveLocationFull(
      label: data.label,
      address: data.address,
      latitude: data.latitude,
      longitude: data.longitude,
      houseNumber: data.houseNumber,
      landmark: data.landmark,
    );
    // ignore: avoid_print
    print('💾 Persisted active location "${data.label}"');
  }

  // ===== Fetch addresses =====
  Future<List<CustomerAddress>> getCustomerAddresses() async {
    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    final response = await _apiService.getCustomerAddresses('Bearer $token');
    // ignore: avoid_print
    print('📥 getCustomerAddresses -> ${response.result.length} rows');
    return response.result;
  }

  // ===== Cached location utilities =====
  Future<void> _cacheLocation({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String? houseNumber,
    String? landmark,
    String? city,
    String? state,
    String? postCode,
    String? addressType, // ➕ ADD THIS PARAMETER
  }) async {
    final locationData = CachedLocationData(
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
      houseNumber: houseNumber,
      landmark: landmark,
      city: city,
      state: state,
      postCode: postCode,
      addressType: addressType, // ➕ ADD THIS: Save to model
      savedAt: DateTime.now(),
    );

    await _database.saveLocationFull(
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
      houseNumber: houseNumber,
      landmark: landmark,
    );

    await _database.saveUserPreference(
      'location_json',
      jsonEncode(locationData.toJson()),
    );

    // Debug
    // ignore: avoid_print
    print(
        '🧩 Cached location -> label:"$label" city:"${city ?? ''}" state:"${state ?? ''}" pin:"${postCode ?? ''}"');
  }

  Future<CachedLocationData?> getCachedLocation() async {
    try {
      final locationJson = await _database.getUserPreference('location_json');
      if (locationJson == null) {
        final active = await _database.getActiveLocation();
        if (active != null) {
          // ignore: avoid_print
          print('🔁 Built CachedLocationData from active row');
          return CachedLocationData(
            label: active['label'],
            address: active['address'],
            latitude: active['latitude'],
            longitude: active['longitude'],
            houseNumber: active['houseNumber'],
            landmark: active['landmark'],
            savedAt: DateTime.parse(active['updatedAt']),
          );
        }
        // ignore: avoid_print
        print('⛔ No cached/active location found');
        return null;
      }
      // ignore: avoid_print
      print('📤 Loaded CachedLocationData from JSON');
      return CachedLocationData.fromJson(jsonDecode(locationJson));
    } catch (_) {
      // ignore: avoid_print
      print('⚠️ getCachedLocation parse failure; returning null');
      return null;
    }
  }

  Future<bool> hasLocationCached() async {
    final v = await _database.hasLocationCached();
    // ignore: avoid_print
    print('🔎 hasLocationCached -> $v');
    return v;
  }

  Future<void> clearLocationCache() async {
    await _database.clearLocationData();
    await _database.removeUserPreference('location_json');
    // ignore: avoid_print
    print('🧹 Cleared local location cache and JSON');
  }

  Future<String?> getLocationSummary() async {
    final l = await getCachedLocation();
    if (l == null) return null;
    final s = '${l.label} - ${l.address}';
    // ignore: avoid_print
    print('🧾 getLocationSummary -> $s');
    return s;
  }

  // ===== Address parsing helpers =====
  Future<Map<String, String?>> _parseAddress(
    double latitude,
    double longitude,
    String fullAddress,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return _parseAddressFromString(fullAddress);
      final p = placemarks.first;
      final result = {
        'city': p.locality ?? p.subAdministrativeArea ?? 'Unknown',
        'state': p.administrativeArea ?? 'Unknown',
        'postCode': p.postalCode ?? '000000',
      };
      // Debug
      // ignore: avoid_print
      print(
          '🧭 _parseAddress -> city:${result['city']} state:${result['state']} pin:${result['postCode']}');
      return result;
    } catch (err) {
      // ignore: avoid_print
      print('⚠️ _parseAddress failed: $err; falling back to string parse');
      return _parseAddressFromString(fullAddress);
    }
  }

  Map<String, String?> _parseAddressFromString(String address) {
    final parts = address.split(',').map((e) => e.trim()).toList();
    final result = {
      'city': parts.length > 1 ? parts[parts.length - 2] : 'Unknown',
      'state': parts.length > 2 ? parts[parts.length - 1] : 'Unknown',
      'postCode': '000000',
    };
    // Debug
    // ignore: avoid_print
    print(
        '✂️ _parseAddressFromString -> city:${result['city']} state:${result['state']} pin:${result['postCode']}');
    return result;
  }
  // ===== Delete Address =====
  Future<bool> deleteCustomerAddress(String addressId) async {
    try {
      final token = await _database.getAuthToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Backend requires body {"addressId": "..."} even for DELETE
      final body = {
        "addressId": addressId
      };

      print('🗑️ Deleting addressId: $addressId');

      final response = await _apiService.deleteCustomerAddress('Bearer $token', body);
      
      print('✅ Delete success: ${response.success}');
      return response.success;
    } catch (e) {
      print('❌ deleteCustomerAddress error: $e');
      // If the error is essentially "success", we can sometimes suppress it, 
      // but usually, we rethrow to let the controller handle it.
      rethrow;
    }
  }
  Future<BaseResponse> updateCustomerAddress({
  required String addressId,
  required String locationId,
  required String addressLine1,
  required String addressLine2,
  required String city,
  required String state,
  required String postCode,
  String? addressType,
}) async {
  final token = await _database.getAuthToken();
  if (token == null) throw Exception('User not authenticated');

  final body = {
    "addressId": addressId,
    "locationId": locationId,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
    "city": city,
    "state": state,
    "postCode": postCode,
    "addressType": addressType ?? "Home",
  };

  // API returns: {"type":"Update address","result":"Address updated successfully."}
  return await _apiService.updateCustomerAddress('Bearer $token', body);
}
}
