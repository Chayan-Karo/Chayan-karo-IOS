// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryEntity _$CategoryEntityFromJson(Map<String, dynamic> json) =>
    CategoryEntity(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      iconPath: json['iconPath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CategoryEntityToJson(CategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'iconPath': instance.iconPath,
      'createdAt': instance.createdAt.toIso8601String(),
    };
