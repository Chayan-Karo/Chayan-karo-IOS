import 'package:get/get.dart';
import '../models/hair_skin_service.dart';

class HairSkinServiceController extends GetxController {
  final RxList<HairSkinService> _services = <HairSkinService>[].obs;
  final RxBool _isLoading = false.obs;

  List<HairSkinService> get services => _services;
  bool get isLoading => _isLoading.value;

  Map<String, List<HairSkinService>> get groupedServices {
    Map<String, List<HairSkinService>> grouped = {};
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
      HairSkinService(
        id: 'classic_haircut',
        title: 'Classic Haircut',
        image: 'assets/z2.webp',
        price: '₹299',
        rating: '4.86',
        duration: '30 mins',
        category: 'Haircut & Styling',
        numericPrice: 299.0,
      ),
      HairSkinService(
        id: 'trendy_hair_styling',
        title: 'Trendy Hair Styling',
        image: 'assets/z2.webp',
        price: '₹499',
        rating: '4.80',
        duration: '40 mins',
        category: 'Haircut & Styling',
        numericPrice: 499.0,
      ),
      
      // Hair Color & Spa
      HairSkinService(
        id: 'global_hair_color',
        title: 'Global Hair Color',
        image: 'assets/s1.webp',
        price: '₹1199',
        rating: '4.78',
        duration: '90 mins',
        category: 'Hair Color & Spa',
        numericPrice: 1199.0,
      ),
      HairSkinService(
        id: 'hair_spa_with_steam',
        title: 'Hair Spa with Steam',
        image: 'assets/s1.webp',
        price: '₹799',
        rating: '4.82',
        duration: '60 mins',
        category: 'Hair Color & Spa',
        numericPrice: 799.0,
      ),
      
      // Beard Grooming
      HairSkinService(
        id: 'beard_trim_shape',
        title: 'Beard Trim & Shape',
        image: 'assets/s2.webp',
        price: '₹199',
        rating: '4.75',
        duration: '20 mins',
        category: 'Beard Grooming',
        numericPrice: 199.0,
      ),
      HairSkinService(
        id: 'beard_spa_hydration',
        title: 'Beard Spa & Hydration',
        image: 'assets/s2.webp',
        price: '₹349',
        rating: '4.80',
        duration: '30 mins',
        category: 'Beard Grooming',
        numericPrice: 349.0,
      ),
      
      // Hair Fall Treatments
      HairSkinService(
        id: 'anti_hair_fall_serum',
        title: 'Anti Hair Fall Serum Therapy',
        image: 'assets/s3.webp',
        price: '₹999',
        originalPrice: '₹1199',
        rating: '4.84',
        duration: '60 mins',
        category: 'Hair Fall Treatments',
        numericPrice: 999.0,
        desc: '• Scalp massage\n• Active ingredients\n• Reduces hair breakage',
      ),
      HairSkinService(
        id: 'dandruff_control_spa',
        title: 'Dandruff Control Spa',
        image: 'assets/s3.webp',
        price: '₹799',
        originalPrice: '₹949',
        rating: '4.77',
        duration: '50 mins',
        category: 'Hair Fall Treatments',
        numericPrice: 799.0,
        desc: '• Clears flaky scalp\n• Antifungal formula\n• Promotes healthy roots',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<HairSkinService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  HairSkinService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
