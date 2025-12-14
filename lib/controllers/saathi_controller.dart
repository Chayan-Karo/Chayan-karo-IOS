import 'package:get/get.dart';
import 'package:intl/intl.dart'; 
import '../data/repository/saathi_repository.dart';
import '../models/saathi_models.dart';

class SaathiController extends GetxController {
  final SaathiRepository _repo;

  SaathiController({SaathiRepository? repo})
      : _repo = repo ?? SaathiRepository();

  /// List of fetched providers
  final RxList<SaathiItem> saathiList = <SaathiItem>[].obs;

  /// Local-only: Providers locked by THIS user
  final RxSet<String> myLockedProviders = <String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxInt selectedIndex = 2.obs;

  /// Currently locking provider
  final RxString lockingProviderId = ''.obs;

  /// Response of last lock
  final Rx<LockProviderResponse?> lastLockResponse =
      Rx<LockProviderResponse?>(null);

  /// Last locked ID
  final RxnString lastLockedProviderId = RxnString(null);

  /// For debounce mode
  final RxString _tapSelection = ''.obs;
  Worker? _debouncer;

  /// Enable / disable immediate lock
  final RxBool preferImmediateLock = true.obs;

  /// We store the date here so we can use it when locking
  DateTime? _currentBookingDate;

  @override
  void onInit() {
    super.onInit();

    _debouncer = debounce<String>(
      _tapSelection,
      (spid) async {
        if (spid.isEmpty) return;
        // _lockNow will pick up the stored _currentBookingDate
        await _lockNow(spid);
      },
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onClose() {
    _debouncer?.dispose();
    super.onClose();
  }

  // -------------------------------------------------------------
  // HELPER: Check Availability (SIMPLIFIED)
  // -------------------------------------------------------------

  /// Returns TRUE if the provider can be tapped.
  /// Since the API filters providers based on slot/duration, 
  /// anyone in the list is "Available" unless they are actively locked.
  bool isProviderAvailable(SaathiItem item) {
    return !item.isLocked;
  }

  // -------------------------------------------------------------
  // FETCH PROVIDERS (UPDATED)
  // -------------------------------------------------------------
  Future<void> fetchProviders({
    required String categoryId,
    required String serviceId,
    required String locationId,
    required String addressId,
    required DateTime bookingDate,
    required int currentBookingDuration,
    String? bookingTime, 
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Capture the date globally
      _currentBookingDate = bookingDate;

      if (categoryId.trim().isEmpty) throw ArgumentError('categoryId missing');
      if (serviceId.trim().isEmpty) throw ArgumentError('serviceId missing');
      if (locationId.trim().isEmpty) throw ArgumentError('locationId missing');
      if (addressId.trim().isEmpty) throw ArgumentError('addressId missing');

      final items = await _repo.getServiceProviders(
        categoryId: categoryId,
        serviceId: serviceId,
        locationId: locationId,
        addressId: addressId,
        bookingDate: bookingDate,
        currentBookingDuration: currentBookingDuration,
        bookingTime: bookingTime, 
      );

      saathiList.assignAll(items);
      error.value = '';
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------------------------------------
  // LOCK ON TAP
  // -------------------------------------------------------------
  Future<LockProviderResponse?> lockOnTap(
    String serviceProviderId, {
    DateTime? bookingDate, // Optional override
  }) async {
    if (serviceProviderId.trim().isEmpty) return null;

    final item = saathiList.firstWhereOrNull((e) => e.id == serviceProviderId);
    if (item == null) return null;

    // Check if SELECTABLE (Tapable)
    if (!isProviderAvailable(item)) {
      return null; 
    }

    // Always update the global date if a specific date is passed.
    if (bookingDate != null) {
      _currentBookingDate = bookingDate;
    }

    lockingProviderId.value = serviceProviderId;

    if (preferImmediateLock.value) {
      final res = await _lockNow(
        serviceProviderId,
        dateOverride: bookingDate,
      );

      if (res?.isSuccess == true) {
        _markProviderAsMine(serviceProviderId);
      }

      return res;
    } else {
      _tapSelection.value = serviceProviderId;
      return null;
    }
  }

  // -------------------------------------------------------------
  // [RESTORED] Simple selection
  // -------------------------------------------------------------
  void onProviderSelected(String serviceProviderId) {
    if (serviceProviderId.trim().isEmpty) return;
    
    final item = saathiList.firstWhereOrNull((e) => e.id == serviceProviderId);
    
    if (item != null && !isProviderAvailable(item)) return;

    lockingProviderId.value = serviceProviderId;
    _tapSelection.value = serviceProviderId;
  }

  // -------------------------------------------------------------
  // [RESTORED] Manual Lock
  // -------------------------------------------------------------
  Future<LockProviderResponse?> lockProviderNow(
      String serviceProviderId) async {
    
    final item = saathiList.firstWhereOrNull((e) => e.id == serviceProviderId);
    if (item != null && !isProviderAvailable(item)) return null;

    final res = await _lockNow(serviceProviderId);

    if (res?.isSuccess == true) {
      _markProviderAsMine(serviceProviderId);
    }

    return res;
  }

  // -------------------------------------------------------------
  // INTERNAL LOCK METHOD
  // -------------------------------------------------------------
  Future<LockProviderResponse?> _lockNow(
    String serviceProviderId, {
    DateTime? dateOverride,
  }) async {
    try {
      error.value = '';

      final dateToUse = dateOverride ?? _currentBookingDate ?? DateTime.now();

      final res = await _repo.lockServiceProvider(
        serviceProviderId: serviceProviderId,
        bookingDate: dateToUse,
      );

      lastLockResponse.value = res;

      if (res.isSuccess) {
        _markProviderAsMine(serviceProviderId);
      }

      return res;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      if (lockingProviderId.value == serviceProviderId) {
        lockingProviderId.value = '';
      }
    }
  }

  // -------------------------------------------------------------
  // LOCAL USER-LOCK STATE
  // -------------------------------------------------------------
  void _markProviderAsMine(String id) {
    myLockedProviders.add(id);
    lastLockedProviderId.value = id;
  }

  // -------------------------------------------------------------
  void onItemTapped(int index) => selectedIndex.value = index;
}