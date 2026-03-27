import 'package:get/get.dart';
import '../models/most_used_service_model.dart';
import '../data/repository/most_used_service_repository.dart';

class MostUsedServiceController extends GetxController {
  final MostUsedServiceRepository _repo = MostUsedServiceRepository();

  var isLoading = true.obs;
  var mostUsedServices = <MostUsedService>[].obs;
  var hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      final services = await _repo.fetchMostUsedServices();
      mostUsedServices.assignAll(services);
      
    } catch (e) {
      print("Error fetching most used services: $e");
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}