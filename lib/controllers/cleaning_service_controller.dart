import 'package:get/get.dart';
import '../models/cleaning_service.dart';

class CleaningServiceController extends GetxController {
  final RxList<CleaningService> _services = <CleaningService>[].obs;
  final RxBool _isLoading = false.obs;

  List<CleaningService> get services => _services;
  bool get isLoading => _isLoading.value;

  Map<String, List<CleaningService>> get groupedServices {
    Map<String, List<CleaningService>> grouped = {};
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
      // Bathroom Cleaning
      CleaningService(
        id: 'basic_bathroom_cleaning',
        title: 'Basic Bathroom Cleaning',
        image: 'assets/z2.webp',
        price: '₹349',
        rating: '4.78',
        duration: '30 mins',
        category: 'Bathroom Cleaning',
        numericPrice: 349.0,
      ),
      CleaningService(
        id: 'deep_bathroom_sanitization',
        title: 'Deep Bathroom Sanitization',
        image: 'assets/z2.webp',
        price: '₹499',
        rating: '4.85',
        duration: '45 mins',
        category: 'Bathroom Cleaning',
        numericPrice: 499.0,
      ),
      
      // Kitchen Cleaning
      CleaningService(
        id: 'basic_kitchen_cleaning',
        title: 'Basic Kitchen Cleaning',
        image: 'assets/s1.webp',
        price: '₹449',
        rating: '4.76',
        duration: '40 mins',
        category: 'Kitchen Cleaning',
        numericPrice: 449.0,
      ),
      CleaningService(
        id: 'deep_kitchen_degreasing',
        title: 'Deep Kitchen Degreasing',
        image: 'assets/s1.webp',
        price: '₹649',
        rating: '4.81',
        duration: '60 mins',
        category: 'Kitchen Cleaning',
        numericPrice: 649.0,
      ),
      
      // Sofa & Carpet Cleaning
      CleaningService(
        id: 'sofa_shampooing_5_seater',
        title: 'Sofa Shampooing (5 Seater)',
        image: 'assets/s2.webp',
        price: '₹799',
        originalPrice: '₹999',
        rating: '4.84',
        duration: '60 mins',
        category: 'Sofa & Carpet Cleaning',
        numericPrice: 799.0,
        desc: '• Removes stains & odor\n• Foam-based cleaning\n• Ideal for fabric sofas',
      ),
      CleaningService(
        id: 'carpet_vacuum_wash',
        title: 'Carpet Vacuum & Wash',
        image: 'assets/s2.webp',
        price: '₹20/sq.ft',
        originalPrice: '₹30/sq.ft',
        rating: '4.79',
        duration: 'Variable',
        category: 'Sofa & Carpet Cleaning',
        numericPrice: 20.0, // Base price per sq.ft
        desc: '• Deep vacuuming\n• Steam and shampoo wash\n• Effective dust removal',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<CleaningService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  CleaningService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
