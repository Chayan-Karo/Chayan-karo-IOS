// viewmodels/salon_services_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/salon_service.dart';

class SalonServicesViewModel extends ChangeNotifier {
  final Map<String, List<SalonService>> _groupedServices;
  final Map<String, int> _cartQuantities = {};

  SalonServicesViewModel() : _groupedServices = _initializeServices();

  Map<String, List<SalonService>> get groupedServices => _groupedServices;
  Map<String, int> get cartQuantities => Map.unmodifiable(_cartQuantities);

  List<SalonService> get cartItems {
    List<SalonService> items = [];
    _cartQuantities.forEach((serviceId, quantity) {
      if (quantity > 0) {
        final service = findServiceById(serviceId);
        if (service != null) items.add(service);
      }
    });
    return items;
  }

  int get cartItemCount => _cartQuantities.values.fold(0, (sum, qty) => sum + qty);
  bool get isCartEmpty => cartItemCount == 0;

  double get totalPrice {
    double total = 0;
    _cartQuantities.forEach((serviceId, quantity) {
      final service = findServiceById(serviceId);
      if (service != null && quantity > 0) {
        final priceString = service.price.replaceAll(RegExp(r'[^\d.]'), '');
        final price = double.tryParse(priceString) ?? 0;
        total += price * quantity;
      }
    });
    return total;
  }

  static Map<String, List<SalonService>> _initializeServices() {
    final Map<String, List<Map<String, String>>> rawData = {
      'Cleanup': [
        {'image': 'assets/z2.webp', 'title': 'Cleanup', 'price': '₹200', 'rating': '4.76', 'duration': '55 mins'},
        {'image': 'assets/z2.webp', 'title': 'Deep Cleanup', 'price': '₹250', 'rating': '4.76', 'duration': '65 mins'},
      ],
      'Bleach & Detan': [
        {'image': 'assets/z1.webp', 'title': 'Bleach', 'price': '₹200', 'rating': '4.76', 'duration': '55 mins'},
        {'image': 'assets/s4.webp', 'title': 'Detan', 'price': '₹180', 'rating': '4.76', 'duration': '45 mins'},
      ],
      'Threading': [
        {'image': 'assets/saloon_threading.webp', 'title': 'Threading', 'price': '₹150', 'rating': '4.8', 'duration': '30 mins'},
      ],
      'Waxing': [
        {'image': 'assets/saloon_waxing.webp', 'title': 'Waxing', 'price': '₹400', 'rating': '4.7', 'duration': '60 mins'},
      ],
      'Manicure': [
        {'image': 'assets/saloon_manicure.webp', 'title': 'Manicure', 'price': '₹300', 'rating': '4.75', 'duration': '45 mins'},
      ],
      'Pedicure': [
        {'image': 'assets/saloon_pedicure.webp', 'title': 'Pedicure', 'price': '₹350', 'rating': '4.8', 'duration': '50 mins'},
      ],
      'Facial': [
        {
          'image': 'assets/s4.webp',
          'title': 'Diamond Facial',
          'price': '₹499',
          'originalPrice': '₹599',
          'rating': '4.76',
          'duration': '55 mins',
          'desc': '• 45 mins\n• For all skin types. Pinacolada mask.\n• 6-step process. Includes 10-min massage',
        },
        {
          'image': 'assets/s1.webp',
          'title': 'Gold Facial',
          'price': '₹699',
          'originalPrice': '₹799',
          'rating': '4.76',
          'duration': '60 mins',
          'desc': '• 60 mins\n• Anti-aging treatment\n• 7-step process. Includes face massage',
        },
      ],
    };

    Map<String, List<SalonService>> groupedServices = {};
    rawData.forEach((category, services) {
      groupedServices[category] = services.asMap().entries.map((entry) {
        return SalonService.fromMap(entry.value, category, entry.key);
      }).toList();
    });

    return groupedServices;
  }

  // Made public for cart integration
  SalonService? findServiceById(String serviceId) {
    for (var services in _groupedServices.values) {
      try {
        return services.firstWhere((service) => service.id == serviceId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  void incrementQuantity(String serviceId) {
    _cartQuantities[serviceId] = (_cartQuantities[serviceId] ?? 0) + 1;
    notifyListeners();
  }

  void decrementQuantity(String serviceId) {
    final currentQuantity = _cartQuantities[serviceId] ?? 0;
    if (currentQuantity > 0) {
      _cartQuantities[serviceId] = currentQuantity - 1;
      if (_cartQuantities[serviceId] == 0) {
        _cartQuantities.remove(serviceId);
      }
      notifyListeners();
    }
  }

  int getQuantity(String serviceId) {
    return _cartQuantities[serviceId] ?? 0;
  }

  bool isInCart(String serviceId) {
    return getQuantity(serviceId) > 0;
  }

  void clearCart() {
    _cartQuantities.clear();
    notifyListeners();
  }
}
