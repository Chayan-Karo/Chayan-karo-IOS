class Service {
  final String id;
  final String title;
  final String image;
  final String price;
  final String? originalPrice;
  final String rating;
  final String duration;
  final String category;
  final String? desc;

  Service({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.duration,
    required this.category,
    this.desc,
  });

  // SAME AS SALON PATTERN - fromMap factory method
  factory Service.fromMap(Map<String, String> map, String category, String id) {
    return Service(
      id: id,
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      price: map['price'] ?? '',
      originalPrice: map['originalPrice'],
      rating: map['rating'] ?? '0.0',
      duration: map['duration'] ?? '',
      category: category,
      desc: map['desc'],
    );
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? '',
      originalPrice: json['originalPrice'],
      rating: json['rating'] ?? '0.0',
      duration: json['duration'] ?? '',
      category: json['category'] ?? '',
      desc: json['desc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'duration': duration,
      'category': category,
      'desc': desc,
    };
  }
}

class CategoryItem {
  final String title;
  final String image;

  CategoryItem({
    required this.title,
    required this.image,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      title: json['title'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
    };
  }
}

class DiscountOffer {
  final String icon;
  final String title;
  final String subtitle;

  DiscountOffer({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  factory DiscountOffer.fromJson(Map<String, dynamic> json) {
    return DiscountOffer(
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
    };
  }
}
