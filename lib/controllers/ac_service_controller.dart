import 'package:get/get.dart';
import '../models/ac_service.dart';

class ACServiceController extends GetxController {
  final RxList<ACService> _services = <ACService>[].obs;
  final RxBool _isLoading = false.obs;

  List<ACService> get services => _services;
  bool get isLoading => _isLoading.value;

  Map<String, List<ACService>> get groupedServices {
    Map<String, List<ACService>> grouped = {};
    for (var service in _services) {
      if (!grouped.containsKey(service.category)) {
        grouped[service.category] = [];
      }
      grouped[service.category]!.add(service);
    }
    return grouped;
  }

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  void loadServices() {
    _isLoading.value = true;
    
    _services.value = [
      // AC Installation
      ACService(
        id: 'split_ac_installation',
        title: 'Split AC Installation',
        image: 'assets/ac_installation.webp',
        price: '₹799',
        rating: '4.81',
        duration: '60 mins',
        category: 'AC Installation',
        numericPrice: 799.0,
      ),
      ACService(
        id: 'window_ac_installation',
        title: 'Window AC Installation',
        image: 'assets/ac_services.webp',
        price: '₹599',
        rating: '4.77',
        duration: '45 mins',
        category: 'AC Installation',
        numericPrice: 599.0,
      ),
      
      // AC Uninstallation
      ACService(
        id: 'split_ac_uninstallation',
        title: 'Split AC Uninstallation',
        image: 'assets/ac_uninstallation.webp',
        price: '₹549',
        rating: '4.75',
        duration: '40 mins',
        category: 'AC Uninstallation',
        numericPrice: 549.0,
      ),
      ACService(
        id: 'window_ac_uninstallation',
        title: 'Window AC Uninstallation',
        image: 'assets/ac_services.webp',
        price: '₹399',
        rating: '4.72',
        duration: '35 mins',
        category: 'AC Uninstallation',
        numericPrice: 399.0,
      ),
      
      // Wet Servicing
      ACService(
        id: 'split_ac_wet_servicing',
        title: 'Split AC Wet Servicing',
        image: 'assets/wet.webp',
        price: '₹699',
        originalPrice: '₹899',
        rating: '4.83',
        duration: '75 mins',
        category: 'Wet Servicing',
        numericPrice: 699.0,
        desc: 'Comprehensive internal cleaning of filters, cooling coils, and blower.',
      ),
      ACService(
        id: 'window_ac_wet_servicing',
        title: 'Window AC Wet Servicing',
        image: 'assets/ac_services.webp',
        price: '₹599',
        originalPrice: '₹749',
        rating: '4.78',
        duration: '60 mins',
        category: 'Wet Servicing',
        numericPrice: 599.0,
        desc: 'Full interior wash including fins, coils, and fan motor area.',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<ACService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  ACService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
