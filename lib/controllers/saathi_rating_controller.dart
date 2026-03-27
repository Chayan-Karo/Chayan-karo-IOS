import 'package:get/get.dart';
import '../data/repository/saathi_rating_repository.dart';
import '../models/saathi_rating_model.dart';

class SaathiRatingController extends GetxController {
  final SaathiRatingRepository _repo;

  SaathiRatingController({SaathiRatingRepository? repo})
      : _repo = repo ?? SaathiRatingRepository();

  final RxList<ProviderRatingItem> reviews = <ProviderRatingItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  Future<void> fetchRatings(String serviceProviderId) async {
    try {
      isLoading.value = true;
      error.value = ''; // Reset error on new fetch
      
      // Repository returns [] on 404, or throws on actual error
      final data = await _repo.getRatings(serviceProviderId);
      
      // REMOVED: Do not set error.value if data is empty.
      // Leaving error as '' tells the UI this is a successful fetch with 0 results.
      
      reviews.assignAll(data);
    } catch (e) {
      // Only set error text for actual failures (500, Network, etc.)
      error.value = "Failed to load reviews. Please try again.";
      print("Rating Fetch Error: $e"); 
    } finally {
      isLoading.value = false;
    }
  }
}