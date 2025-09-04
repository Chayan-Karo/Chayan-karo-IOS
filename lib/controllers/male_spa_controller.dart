import 'package:get/get.dart';
import '../models/male_spa_service.dart';

class MaleSpaController extends GetxController {
  final RxList<MaleSpaService> _services = <MaleSpaService>[].obs;
  final RxBool _isLoading = false.obs;

  List<MaleSpaService> get services => _services;
  bool get isLoading => _isLoading.value;

  // Group services by category
  Map<String, List<MaleSpaService>> get groupedServices {
    Map<String, List<MaleSpaService>> grouped = {};
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
      // Sports & Deep Tissue Massage
      MaleSpaService(
        id: 'sports_recovery_massage',
        title: 'Sports Recovery Massage',
        image: 'assets/z2.webp',
        price: '₹899',
        rating: '4.85',
        duration: '60 mins',
        category: 'Sports & Deep Tissue Massage',
        numericPrice: 899.0,
      ),
      MaleSpaService(
        id: 'deep_tissue_therapy',
        title: 'Deep Tissue Therapy',
        image: 'assets/z2.webp',
        price: '₹999',
        rating: '4.88',
        duration: '75 mins',
        category: 'Sports & Deep Tissue Massage',
        numericPrice: 999.0,
      ),
      
      // Head & Neck Therapy
      MaleSpaService(
        id: 'ayurvedic_head_massage',
        title: 'Ayurvedic Head Massage',
        image: 'assets/s1.webp',
        price: '₹399',
        rating: '4.76',
        duration: '30 mins',
        category: 'Head & Neck Therapy',
        numericPrice: 399.0,
      ),
      MaleSpaService(
        id: 'neck_shoulder_relief',
        title: 'Neck & Shoulder Relief',
        image: 'assets/s1.webp',
        price: '₹449',
        rating: '4.78',
        duration: '35 mins',
        category: 'Head & Neck Therapy',
        numericPrice: 449.0,
      ),
      
      // Charcoal Body Polishing
      MaleSpaService(
        id: 'charcoal_scrub_polish',
        title: 'Charcoal Scrub Polish',
        image: 'assets/s2.webp',
        price: '₹999',
        rating: '4.82',
        duration: '60 mins',
        category: 'Charcoal Body Polishing',
        numericPrice: 999.0,
      ),
      MaleSpaService(
        id: 'brightening_polish',
        title: 'Brightening Polish',
        image: 'assets/s2.webp',
        price: '₹1099',
        rating: '4.80',
        duration: '70 mins',
        category: 'Charcoal Body Polishing',
        numericPrice: 1099.0,
      ),
      
      // Aromatherapy for Men
      MaleSpaService(
        id: 'mint_oil_therapy',
        title: 'Mint Oil Therapy',
        image: 'assets/s3.webp',
        price: '₹849',
        originalPrice: '₹999',
        rating: '4.79',
        duration: '60 mins',
        category: 'Aromatherapy for Men',
        numericPrice: 849.0,
        desc: '• Cooling mint oils\n• Mental clarity\n• Relieves fatigue',
      ),
      MaleSpaService(
        id: 'woody_aroma_massage',
        title: 'Woody Aroma Massage',
        image: 'assets/s3.webp',
        price: '₹899',
        originalPrice: '₹999',
        rating: '4.82',
        duration: '65 mins',
        category: 'Aromatherapy for Men',
        numericPrice: 899.0,
        desc: '• Sandal & cedar oils\n• Uplifting & calming\n• Masculine scent blend',
      ),
    ];
    
    _isLoading.value = false;
  }

  List<MaleSpaService> getServicesByCategory(String category) {
    return _services.where((service) => service.category == category).toList();
  }

  MaleSpaService? getServiceById(String id) {
    try {
      return _services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
