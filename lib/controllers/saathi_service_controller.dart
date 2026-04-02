import 'package:get/get.dart';
import '../data/repository/saathi_service_repo.dart';
import '../models/provider_service_model.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class SaathiServiceController extends GetxController {
  final SaathiServiceRepository _repo;
  final String providerId;

  // Constructor matching your project's pattern:
  // 1. providerId is required (context for the screen)
  // 2. repo is optional (defaults to new instance using the Repo defined above)
  SaathiServiceController({
    required this.providerId,
    SaathiServiceRepository? repo,
  }) : _repo = repo ?? SaathiServiceRepository();

  final RxList<ProviderServiceItem> serviceList = <ProviderServiceItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      error.value = '';

      // The Repository now handles getting the token from AppDatabase
      final items = await _repo.getServices(providerId);
      
      serviceList.assignAll(items);

    } catch (e) {
      error.value = e.toString();
      // Optional: Print error for debugging
      print("Error fetching provider services: $e");
    } finally {
      isLoading.value = false;
    }
  }
  /// Check if the provider is available for the specific slot and duration
  Future<bool> checkProviderAvailability({
    required String providerId,
    required String addressId,
    required DateTime dateTime,
    required int totalDurationMinutes,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true; // Show loader

      final dateStr = DateFormat('yyyy-MM-dd').format(dateTime);
      final timeStr = DateFormat('HH:mm').format(dateTime); // 24-hour format for API

      final isAvailable = await _repo.checkAvailability(
        providerId: providerId,
        addressId: addressId,
        bookingDate: dateStr,
        bookingTime: timeStr,
        duration: totalDurationMinutes,
        categoryId: categoryId,
      );

      return isAvailable;
    } catch (e) {
      // Return false and let UI handle the error message display or rethrow
      // For now, we store error string to display in UI
      error.value = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      isLoading.value = false; // Hide loader
    }
  }
}