// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryResponse _$CategoryResponseFromJson(Map<String, dynamic> json) =>
    CategoryResponse(
      type: json['type'] as String,
      result: (json['result'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryResponseToJson(CategoryResponse instance) =>
    <String, dynamic>{'type': instance.type, 'result': instance.result};

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String,
  imgLink: json['imgLink'] as String,
  bannerLink: json['bannerLink'] as String?,
  serviceCategory: (json['serviceCategory'] as List<dynamic>)
      .map((e) => ServiceSubCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'imgLink': instance.imgLink,
  'bannerLink': instance.bannerLink,
  'serviceCategory': instance.serviceCategory,
};

ServiceSubCategory _$ServiceSubCategoryFromJson(Map<String, dynamic> json) =>
    ServiceSubCategory(
      serviceCategoryId: json['serviceCategoryId'] as String,
      serviceCategoryName: json['serviceCategoryName'] as String,
      imgLink: json['imgLink'] as String,
    );

Map<String, dynamic> _$ServiceSubCategoryToJson(ServiceSubCategory instance) =>
    <String, dynamic>{
      'serviceCategoryId': instance.serviceCategoryId,
      'serviceCategoryName': instance.serviceCategoryName,
      'imgLink': instance.imgLink,
    };
