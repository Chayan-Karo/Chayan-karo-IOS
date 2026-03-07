import 'package:get/get.dart';
import '../data/repository/booked_saathi_repository.dart';
import '../models/booked_saathi_model.dart';

class BookedSaathiController extends GetxController {
  final BookedSaathiRepository _repo;

  BookedSaathiController({BookedSaathiRepository? repo})
      : _repo = repo ?? BookedSaathiRepository();

  final RxList<BookedSaathiItem> saathiList = <BookedSaathiItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt selectedIndex = 2.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBookedProviders();
  }

  Future<void> fetchBookedProviders() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final items = await _repo.getBookedProviders();
      saathiList.assignAll(items);
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    // Add logic to navigate to other screens if needed, 
    // similar to your main SaathiController logic
  }
}