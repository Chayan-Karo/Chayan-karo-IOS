import 'package:json_annotation/json_annotation.dart';

part 'cart_models.g.dart';

@JsonEnum()
enum ServiceType {
  @JsonValue('salon')
  salon,
  @JsonValue('spa')
  spa,
  @JsonValue('general')
  general
}

@JsonSerializable()
class CartItem {
  final String id;
  final String title;
  final String image;
  final double price;
  final int quantity;
  final String? description;
  final String? rating;
  final String? duration;
  final String? originalPrice;
  final ServiceType type;

  // New fields for source tracking
  final String? sourcePage;
  final String? sourceTitle;

  // New: category id for provider search
  final String? categoryId; // NEW

  // New field: date added to cart
  final DateTime dateAdded;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final dynamic service;

  CartItem({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.quantity,
    this.description,
    this.rating,
    this.duration,
    this.originalPrice,
    this.type = ServiceType.general,
    this.sourcePage,
    this.sourceTitle,
    this.categoryId, // NEW
    required this.dateAdded,
    this.service,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  double get totalPrice => price * quantity;
  bool get isSalonService => type == ServiceType.salon;
  bool get isSpaService => type == ServiceType.spa;
  String get formattedPrice => '₹${price.toInt()}';

  CartItem copyWith({
    String? id,
    String? title,
    String? image,
    double? price,
    int? quantity,
    String? description,
    String? rating,
    String? duration,
    String? originalPrice,
    ServiceType? type,
    String? sourcePage,
    String? sourceTitle,
    String? categoryId, // NEW
    DateTime? dateAdded,
    dynamic service,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
      originalPrice: originalPrice ?? this.originalPrice,
      type: type ?? this.type,
      sourcePage: sourcePage ?? this.sourcePage,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      categoryId: categoryId ?? this.categoryId, // NEW
      dateAdded: dateAdded ?? this.dateAdded,
      service: service ?? this.service,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
