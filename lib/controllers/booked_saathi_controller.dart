import 'package:get/get.dart';
import '../data/repository/booked_saathi_repository.dart';
import '../models/booked_saathi_model.dart';
import '../data/local/database.dart';

class BookedSaathiController extends GetxController {
  final BookedSaathiRepository _repo;

  BookedSaathiController({BookedSaathiRepository? repo})
      : _repo = repo ?? BookedSaathiRepository();

  final RxBool isLoggedIn = false.obs;
  final RxList<BookedSaathiItem> saathiList = <BookedSaathiItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxInt selectedIndex = 2.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthAndFetch();
    fetchBookedProviders();
  }
  Future<void> checkAuthAndFetch() async {
    try {
      final db = Get.find<AppDatabase>();
      final bool authStatus = await db.isUserLoggedIn();
      
      isLoggedIn.value = authStatus;

      if (authStatus) {
        print('🔐 SaathiCtrl: User Logged In. Fetching providers...');
        fetchBookedProviders();
      } else {
        print('👤 SaathiCtrl: Guest Mode. Skipping API.');
        saathiList.clear();
        isLoading.value = false;
      }
    } catch (e) {
      print('❌ SaathiCtrl AuthCheck Error: $e');
      isLoggedIn.value = false;
    }
  }

  Future<void> fetchBookedProviders() async {
    final db = Get.find<AppDatabase>();
    if (!(await db.isUserLoggedIn())) {
      isLoggedIn.value = false;
      return;
    }
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