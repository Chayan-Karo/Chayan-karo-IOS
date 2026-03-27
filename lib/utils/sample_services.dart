// utils/sample_services.dart
import '../models/service_model.dart';

class SampleServices {
  static List<ServiceModel> getGroomingServices() {
    return [
      ServiceModel(
        id: '1',
        name: 'Diamond Facial',
        price: 699,
        duration: '45 mins',
        description: 'For all skin types. Pinacolada mask.\n6-step process. Includes 10-min massage',
        imagePath: 'assets/images/diamond_facial.jpg',
      ),
      ServiceModel(
        id: '2',
        name: 'Hair Cut & Styling',
        price: 299,
        duration: '30 mins',
        description: 'Professional haircut with styling.\nIncludes hair wash and blow dry',
        imagePath: 'assets/images/haircut.jpg',
      ),
      ServiceModel(
        id: '3',
        name: 'Beard Trim & Shape',
        price: 199,
        duration: '20 mins',
        description: 'Professional beard trimming and shaping.\nIncludes face cleanup',
        imagePath: 'assets/images/beard_trim.jpg',
      ),
      ServiceModel(
        id: '4',
        name: 'Full Body Massage',
        price: 899,
        duration: '60 mins',
        description: 'Relaxing full body massage.\nUses premium oils and techniques',
        imagePath: 'assets/images/massage.jpg',
      ),
    ];
  }

  static List<ServiceModel> getBeautyServices() {
    return [
      ServiceModel(
        id: '5',
        name: 'Manicure & Pedicure',
        price: 599,
        duration: '50 mins',
        description: 'Complete nail care service.\nIncludes cuticle care and polish',
        imagePath: 'assets/images/manicure.jpg',
      ),
      ServiceModel(
        id: '6',
        name: 'Eyebrow Threading',
        price: 149,
        duration: '15 mins',
        description: 'Professional eyebrow shaping.\nPrecise threading technique',
        imagePath: 'assets/images/eyebrow.jpg',
      ),
      ServiceModel(
        id: '7',
        name: 'Face Cleanup',
        price: 399,
        duration: '40 mins',
        description: 'Deep cleansing facial treatment.\nRemoves blackheads and impurities',
        imagePath: 'assets/images/cleanup.jpg',
      ),
    ];
  }

  static List<ServiceModel> getWellnessServices() {
    return [
      ServiceModel(
        id: '8',
        name: 'Swedish Massage',
        price: 799,
        duration: '60 mins',
        description: 'Relaxing full body Swedish massage.\nRelieves stress and muscle tension',
        imagePath: 'assets/images/swedish_massage.jpg',
      ),
      ServiceModel(
        id: '9',
        name: 'Aromatherapy',
        price: 699,
        duration: '45 mins',
        description: 'Therapeutic aromatherapy session.\nUses essential oils for relaxation',
        imagePath: 'assets/images/aromatherapy.jpg',
      ),
    ];
  }

  // Generic method to get services by category name
  static List<ServiceModel> getServicesByCategory(String categoryTitle) {
    switch (categoryTitle.toLowerCase()) {
      case 'grooming':
      case 'grooming services':
      case 'men grooming':
        return getGroomingServices();
      case 'beauty':
      case 'beauty services':
      case 'women beauty':
        return getBeautyServices();
      case 'wellness':
      case 'wellness services':
      case 'spa':
        return getWellnessServices();
      default:
        return getGroomingServices(); // Default fallback
    }
  }
}
