import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/female_spa_models.dart';

class FemaleSpaController extends GetxController {
  final ScrollController scrollController = ScrollController();
  var groupedServices = <String, List<Service>>{}.obs;
  var cartQuantities = <String, int>{}.obs;

  // Category keys for scrolling navigation - USING YOUR ORIGINAL CATEGORIES
  final Map<String, GlobalKey> categoryKeys = {
    'Body Massage': GlobalKey(),
    'Face Treatment': GlobalKey(),
    'Body Scrub': GlobalKey(),
    'Aromatherapy': GlobalKey(),
    'Body Wrap': GlobalKey(),
    'Manicure': GlobalKey(),
    'Pedicure': GlobalKey(),
  };

  // Service to category mapping for direct scrolling
  final Map<String, String> _serviceToCategory = {
    'body_massage': 'Body Massage',
    'face_treatment': 'Face Treatment',
    'body_scrub': 'Body Scrub',
    'aromatherapy': 'Aromatherapy',
    'body_wrap': 'Body Wrap',
    'manicure': 'Manicure',
    'pedicure': 'Pedicure',
  };

  // Category grid to section mapping - USING YOUR ORIGINAL MAPPING
  final Map<String, String> _categoryGridToSection = {
    'Body Massage': 'Body Massage',
    'Face Treatment': 'Face Treatment',
    'Body Scrub': 'Body Scrub',
    'Aromatherapy': 'Aromatherapy',
    'Body Treatments': 'Body Wrap',
    'Hand & Foot Care': 'Manicure',
  };

  @override
  void onInit() {
    super.onInit();
    groupedServices.value = _initializeServices();
  }

  Map<String, List<Service>> _initializeServices() {
    // USING YOUR ORIGINAL ASSETS AND SERVICE NAMES FROM VIEWMODEL
    final Map<String, List<Map<String, String>>> rawData = {
      'Body Massage': [
        {
          'image': 'assets/z2.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Full Body Massage',
          'price': '₹1500',
          'rating': '4.8',
          'duration': '90 mins',
        },
        {
          'image': 'assets/s1.webp', // USING YOUR ORIGINAL ASSET  
          'title': 'Swedish Massage',
          'price': '₹1800',
          'rating': '4.7',
          'duration': '60 mins',
        },
        {
          'image': 'assets/s2.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Deep Tissue Massage',
          'price': '₹2000',
          'originalPrice': '₹2300',
          'rating': '4.9',
          'duration': '75 mins',
        },
      ],
      'Face Treatment': [
        {
          'image': 'assets/s3.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Facial Treatment',
          'price': '₹1200',
          'originalPrice': '₹1500',
          'rating': '4.8',
          'duration': '60 mins',
          'desc': '• 60 mins\n• Advanced facial treatment\n• Deep cleansing and hydration'
        },
        {
          'image': 'assets/s4.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Anti-Aging Facial',
          'price': '₹1800',
          'rating': '4.7',
          'duration': '75 mins',
          'desc': '• 75 mins\n• Specialized treatment\n• Reduces signs of aging'
        },
        {
          'image': 'assets/s5.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Gold Facial',
          'price': '₹2500',
          'originalPrice': '₹3000',
          'rating': '4.9',
          'duration': '90 mins',
          'desc': '• 90 mins\n• Luxurious gold-infused facial\n• Ultimate skin rejuvenation'
        },
      ],
      'Body Scrub': [
        {
          'image': 'assets/z1.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Body Scrub Treatment',
          'price': '₹800',
          'rating': '4.6',
          'duration': '45 mins',
        },
        {
          'image': 'assets/z2.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Exfoliating Scrub',
          'price': '₹1000',
          'originalPrice': '₹1200',
          'rating': '4.7',
          'duration': '50 mins',
        },
      ],
      'Aromatherapy': [
        {
          'image': 'assets/s1.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Lavender Aromatherapy',
          'price': '₹1400',
          'rating': '4.8',
          'duration': '60 mins',
          'desc': '• 60 mins\n• Calming lavender session\n• Ultimate relaxation experience'
        },
        {
          'image': 'assets/s2.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Essential Oil Therapy',
          'price': '₹1600',
          'originalPrice': '₹1800',
          'rating': '4.7',
          'duration': '65 mins',
          'desc': '• 65 mins\n• Refreshing therapy\n• Mental clarity and stress relief'
        },
        {
          'image': 'assets/s3.webp', // USING YOUR ORIGINAL ASSET
          'title': 'Relaxation Therapy',
          'price': '₹1800',
          'rating': '4.9',
          'duration': '70 mins',
          'desc': '• 70 mins\n• Complete relaxation\n• Skin rejuvenation and relaxation'
        },
      ],
      
    };

    Map<String, List<Service>> groupedServices = {};
    
    rawData.forEach((category, services) {
      groupedServices[category] = services.asMap().entries.map((entry) {
        // Generate a unique ID by combining category and index
        String uniqueId = '${category.toLowerCase().replaceAll(' ', '_')}_${entry.key}';
        return Service.fromMap(
          entry.value, 
          category, 
          uniqueId  // Convert int index to meaningful String ID
        );
      }).toList();
    });

    return groupedServices;
  }

  Service? findServiceById(String serviceId) {
    for (var services in groupedServices.values) {
      try {
        return services.firstWhere((service) => service.id == serviceId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  int getQuantity(String serviceId) => cartQuantities[serviceId] ?? 0;
  bool isInCart(String serviceId) => getQuantity(serviceId) > 0;

  void incrementQuantity(String serviceId) {
    cartQuantities[serviceId] = (cartQuantities[serviceId] ?? 0) + 1;
  }

  void decrementQuantity(String serviceId) {
    final currentQuantity = cartQuantities[serviceId] ?? 0;
    if (currentQuantity > 0) {
      cartQuantities[serviceId] = currentQuantity - 1;
      if (cartQuantities[serviceId] == 0) {
        cartQuantities.remove(serviceId);
      }
    }
  }

  int get cartItemCount => cartQuantities.values.fold(0, (sum, qty) => sum + qty);
  bool get isCartEmpty => cartItemCount == 0;

  double get totalPrice {
    double total = 0;
    cartQuantities.forEach((serviceId, quantity) {
      final service = findServiceById(serviceId);
      if (service != null && quantity > 0) {
        final priceString = service.price.replaceAll(RegExp(r'[^\d.]'), '');
        final price = double.tryParse(priceString) ?? 0;
        total += price * quantity;
      }
    });
    return total;
  }

  void clearCart() {
    cartQuantities.clear();
  }

  // Navigation methods - SAME AS SALON PATTERN
  void scrollToService(String serviceId) {
    String? categoryName = _serviceToCategory[serviceId];
    if (categoryName != null) {
      scrollToCategory(categoryName);
    }
  }

  void scrollToCategory(String categoryName) {
    final key = categoryKeys[categoryName];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void onCategoryGridTap(String categoryTitle) {
    String? targetSection = _categoryGridToSection[categoryTitle];
    if (targetSection != null) {
      scrollToCategory(targetSection);
    } else {
      scrollToCategory('Aromatherapy');
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
