import 'package:get/get.dart';
import '../models/male_salon_service.dart';

class MaleSalonController extends GetxController {
  final RxList<MaleSalonService> _services = <MaleSalonService>[].obs;
  final RxBool _isLoading = false.obs;

  List<MaleSalonService> get services => _services;
  bool get isLoading => _isLoading.value;

  Map<String, List<MaleSalonService>> get groupedServices {
    Map<String, List<MaleSalonService>> grouped = {};
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
      // Haircut & Styling
      MaleSalonService(
        id: 'classic_haircut',
        title: 'Classic Haircut',
        image: 'assets/ms1.webp',
        price: '₹299',
        rating: '4.86',
        duration: '55 mins',
        category: 'Haircut & Styling',
        numericPrice: 299.0,
      ),
      MaleSalonService(
        id: 'hair_styling',
        title: 'Hair Styling',
        image: 'assets/ms1.webp',
        price: '₹249',
        rating: '4.76',
        duration: '25 mins',
        category: 'Haircut & Styling',
        numericPrice: 249.0,
      ),
      
      // Beard Grooming
      MaleSalonService(
        id: 'beard_trim_shape',
        title: 'Beard Trim & Shape',
        image: 'assets/ms2.webp',
        price: '₹199',
        rating: '4.64',
        duration: '20 mins',
        category: 'Beard Grooming',
        numericPrice: 199.0,
      ),
      MaleSalonService(
        id: 'beard_styling',
        title: 'Beard Styling',
        image: 'assets/ms2.webp',
        price: '₹249',
        rating: '4.85',
        duration: '25 mins',
        category: 'Beard Grooming',
        numericPrice: 249.0,
      ),
      
      // Facials & Cleanup
      MaleSalonService(
        id: 'charcoal_facial',
        title: 'Charcoal Facial',
        image: 'assets/ms7.webp',
        price: '₹499',
        originalPrice: '₹599',
        rating: '4.77',
        duration: '45 mins',
        category: 'Facials & Cleanup',
        numericPrice: 499.0,
        desc: '• Deep cleanse\n• Exfoliating mask\n• Massage therapy',
      ),
      MaleSalonService(
        id: 'fruit_cleanup',
        title: 'Fruit Cleanup',
        image: 'assets/ms8.webp',
        price: '₹399',
        originalPrice: '₹499',
        rating: '4.94',
        duration: '40 mins',
        category: 'Facials & Cleanup',
        numericPrice: 399.0,
        desc: '• Gentle exfoliation\n• Hydrating fruit mask\n• Soothing gel finish',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<MaleSalonService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  MaleSalonService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
