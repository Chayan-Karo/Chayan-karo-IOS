import 'female_spa_models.dart';
class SalonService {
  final String id;
  final String title;
  final String image;
  final String price;
  final String rating;
  final String duration;
  final String category;
  final String? originalPrice;
  final String? desc;

  SalonService({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.rating,
    required this.duration,
    required this.category,
    this.originalPrice,
    this.desc,
  });

  // ADD THIS FACTORY CONSTRUCTOR FOR SERVICE CONVERSION
  factory SalonService.fromService(Service service) {
    return SalonService(
      id: service.id,
      title: service.title,
      image: service.image,
      price: service.price,
      rating: service.rating,
      duration: service.duration,
      category: service.category,
      originalPrice: service.originalPrice,
      desc: service.desc,
    );
  }

  // Your existing fromMap factory method
  factory SalonService.fromMap(Map<String, dynamic> map, String category, String id) {
    return SalonService(
      id: id, // Use the key as ID
      title: map['title'] as String? ?? '',
      image: map['image'] as String? ?? '',
      price: map['price'] as String? ?? '0',
      rating: map['rating'] as String? ?? '0',
      duration: map['duration'] as String? ?? '',
      category: category,
      originalPrice: map['originalPrice'] as String?,
      desc: map['desc'] as String?,
    );
  }

  // Helper method to create list from Map with entries
  static List<SalonService> listFromMap(Map<String, dynamic> data, String category) {
    return data.entries.map((entry) {
      return SalonService.fromMap(entry.value as Map<String, dynamic>, category, entry.key);
    }).toList();
  }

  // Helper method to get numeric price value
  double get numericPrice {
    return double.tryParse(price.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'price': price,
      'rating': rating,
      'duration': duration,
      'category': category,
      'originalPrice': originalPrice,
      'desc': desc,
    };
  }

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      price: json['price'] as String? ?? '0',
      rating: json['rating'] as String? ?? '0',
      duration: json['duration'] as String? ?? '',
      category: json['category'] as String? ?? '',
      originalPrice: json['originalPrice'] as String?,
      desc: json['desc'] as String?,
    );
  }
}
