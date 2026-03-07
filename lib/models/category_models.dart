// lib/models/category_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'category_models.g.dart';

@JsonSerializable()
class CategoryResponse {
  @JsonKey(name: 'type')
  final String type;
  
  @JsonKey(name: 'result')
  final List<Category> result;

  CategoryResponse({
    required this.type,
    required this.result,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) => 
      _$CategoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(name: 'categoryId')
  final String categoryId;
  
  @JsonKey(name: 'categoryName')
  final String categoryName;
  
  @JsonKey(name: 'imgLink')
  final String imgLink;
  // Add this line
  @JsonKey(name: 'bannerLink')
  final String? bannerLink;
  
  @JsonKey(name: 'serviceCategory')
  final List<ServiceSubCategory> serviceCategory;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.imgLink,
    this.bannerLink,
    required this.serviceCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) => 
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class ServiceSubCategory {
  @JsonKey(name: 'serviceCategoryId')
  final String serviceCategoryId;
  
  @JsonKey(name: 'serviceCategoryName')
  final String serviceCategoryName;
  
  @JsonKey(name: 'imgLink')
  final String imgLink;

  ServiceSubCategory({
    required this.serviceCategoryId,
    required this.serviceCategoryName,
    required this.imgLink,
  });

  factory ServiceSubCategory.fromJson(Map<String, dynamic> json) => 
      _$ServiceSubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceSubCategoryToJson(this);
}
