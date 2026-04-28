import 'package:get/get.dart';
import '../models/banner_model.dart';
import '../data/repository/banner_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class BannerController extends GetxController {
  // Inject the repository specifically for banners
  final BannerRepository _repository = BannerRepository();

  // Observable states
  var isLoading = false.obs;
  var banners = <BannerItem>[].obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  /// Fetches banners from the API and updates the local state
  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final result = await _repository.getHomeBanners();

      // Filter active banners only before assigning
      banners.assignAll(
        result.where((banner) => banner.isActive == true).toList(),
      );
      FirebaseAnalytics.instance.logEvent(
        name: 'banner_loaded',
        parameters: {'banner_count': banners.length},
      );
    } catch (e) {
      print("BannerController Error: $e");
      hasError.value = true;
      banners.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh method to be called by a Pull-to-Refresh widget if needed
  Future<void> refreshBanners() async {
    await fetchBanners();
  }
}
