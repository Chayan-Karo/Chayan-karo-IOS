import 'package:get/get.dart';
import '../models/home_repair_service.dart';

class HomeRepairServiceController extends GetxController {
  final RxList<HomeRepairService> _services = <HomeRepairService>[].obs;
  final RxBool _isLoading = false.obs;

  List<HomeRepairService> get services => _services;
  bool get isLoading => _isLoading.value;

  Map<String, List<HomeRepairService>> get groupedServices {
    Map<String, List<HomeRepairService>> grouped = {};
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
      // Electrician Services
      HomeRepairService(
        id: 'fan_light_installation',
        title: 'Fan/Light Installation',
        image: 'assets/z2.webp',
        price: '₹249',
        rating: '4.76',
        duration: '30 mins',
        category: 'Electrician Services',
        numericPrice: 249.0,
      ),
      HomeRepairService(
        id: 'power_socket_repair',
        title: 'Power Socket Repair',
        image: 'assets/z2.webp',
        price: '₹199',
        rating: '4.78',
        duration: '25 mins',
        category: 'Electrician Services',
        numericPrice: 199.0,
      ),
      
      // Plumber Services
      HomeRepairService(
        id: 'tap_faucet_installation',
        title: 'Tap/Faucet Installation',
        image: 'assets/s1.webp',
        price: '₹199',
        rating: '4.74',
        duration: '30 mins',
        category: 'Plumber Services',
        numericPrice: 199.0,
      ),
      HomeRepairService(
        id: 'drain_blockage_fix',
        title: 'Drain Blockage Fix',
        image: 'assets/s1.webp',
        price: '₹299',
        rating: '4.79',
        duration: '40 mins',
        category: 'Plumber Services',
        numericPrice: 299.0,
      ),
      
      // Carpentry Works
      HomeRepairService(
        id: 'furniture_repair',
        title: 'Furniture Repair',
        image: 'assets/s2.webp',
        price: '₹349',
        rating: '4.82',
        duration: '50 mins',
        category: 'Carpentry Works',
        numericPrice: 349.0,
      ),
      HomeRepairService(
        id: 'wall_shelf_mounting',
        title: 'Wall Shelf Mounting',
        image: 'assets/s2.webp',
        price: '₹299',
        rating: '4.80',
        duration: '45 mins',
        category: 'Carpentry Works',
        numericPrice: 299.0,
      ),
      
      // Wall Painting
      HomeRepairService(
        id: 'one_wall_painting',
        title: '1 Wall Painting',
        image: 'assets/s3.webp',
        price: '₹699',
        originalPrice: '₹849',
        rating: '4.75',
        duration: '3 hrs',
        category: 'Wall Painting',
        numericPrice: 699.0,
        desc: '• Labor + basic paint\n• Up to 100 sq. ft.\n• Patch & polish included',
      ),
      HomeRepairService(
        id: 'touch_up_repainting',
        title: 'Touch-up & Repainting',
        image: 'assets/s3.webp',
        price: '₹499',
        originalPrice: '₹699',
        rating: '4.78',
        duration: '2 hrs',
        category: 'Wall Painting',
        numericPrice: 499.0,
        desc: '• Covers patch cracks\n• Roller/brush finish\n• Paint cost separate',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<HomeRepairService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  HomeRepairService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
