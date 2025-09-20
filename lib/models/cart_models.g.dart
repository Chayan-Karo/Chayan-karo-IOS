// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: json['id'] as String,
  title: json['title'] as String,
  image: json['image'] as String,
  price: (json['price'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  description: json['description'] as String?,
  rating: json['rating'] as String?,
  duration: json['duration'] as String?,
  originalPrice: json['originalPrice'] as String?,
  type:
      $enumDecodeNullable(_$ServiceTypeEnumMap, json['type']) ??
      ServiceType.general,
  sourcePage: json['sourcePage'] as String?,
  sourceTitle: json['sourceTitle'] as String?,
  dateAdded: DateTime.parse(json['dateAdded'] as String),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'image': instance.image,
  'price': instance.price,
  'quantity': instance.quantity,
  'description': instance.description,
  'rating': instance.rating,
  'duration': instance.duration,
  'originalPrice': instance.originalPrice,
  'type': _$ServiceTypeEnumMap[instance.type]!,
  'sourcePage': instance.sourcePage,
  'sourceTitle': instance.sourceTitle,
  'dateAdded': instance.dateAdded.toIso8601String(),
};

const _$ServiceTypeEnumMap = {
  ServiceType.salon: 'salon',
  ServiceType.spa: 'spa',
  ServiceType.general: 'general',
};
