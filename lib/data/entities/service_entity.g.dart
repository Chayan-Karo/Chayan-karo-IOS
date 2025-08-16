// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceEntity _$ServiceEntityFromJson(Map<String, dynamic> json) =>
    ServiceEntity(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imagePath: json['imagePath'] as String,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ServiceEntityToJson(ServiceEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imagePath': instance.imagePath,
      'price': instance.price,
      'category': instance.category,
      'rating': instance.rating,
      'createdAt': instance.createdAt.toIso8601String(),
    };
