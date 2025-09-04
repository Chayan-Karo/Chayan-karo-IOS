class HairSkinService {
  final String id;
  final String title;
  final String image;
  final String price;
  final String? originalPrice;
  final String rating;
  final String duration;
  final String? desc;
  final String category;
  final double numericPrice;

  HairSkinService({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.duration,
    this.desc,
    required this.category,
    required this.numericPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'duration': duration,
      'desc': desc,
      'category': category,
      'numericPrice': numericPrice,
    };
  }

  factory HairSkinService.fromMap(Map<String, dynamic> map) {
    return HairSkinService(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      price: map['price'] ?? '',
      originalPrice: map['originalPrice'],
      rating: map['rating'] ?? '',
      duration: map['duration'] ?? '',
      desc: map['desc'],
      category: map['category'] ?? '',
      numericPrice: map['numericPrice']?.toDouble() ?? 0.0,
    );
  }
}
