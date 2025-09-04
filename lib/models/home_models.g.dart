// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceCategory _$ServiceCategoryFromJson(Map<String, dynamic> json) =>
    ServiceCategory(
      title: json['title'] as String,
      icon: json['icon'] as String,
    );

Map<String, dynamic> _$ServiceCategoryToJson(ServiceCategory instance) =>
    <String, dynamic>{
      'title': instance.title,
      'icon': instance.icon,
    };

GoToService _$GoToServiceFromJson(Map<String, dynamic> json) => GoToService(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$GoToServiceToJson(GoToService instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'images': instance.images,
    };

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      image: json['image'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'image': instance.image,
      'title': instance.title,
      'imagePath': instance.imagePath,
      'label': instance.label,
    };

Banner _$BannerFromJson(Map<String, dynamic> json) => Banner(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$BannerToJson(Banner instance) => <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'image': instance.image,
    };

HomeData _$HomeDataFromJson(Map<String, dynamic> json) => HomeData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      goToServices: (json['goToServices'] as List<dynamic>)
          .map((e) => GoToService.fromJson(e as Map<String, dynamic>))
          .toList(),
      mostUsedServices: (json['mostUsedServices'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      acRepairItems: (json['acRepairItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      appliancesRepairItems: (json['appliancesRepairItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      maleSpaItems: (json['maleSpaItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      salonMenItems: (json['salonMenItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      saloonWomenItems: (json['saloonWomenItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      spaWomenItems: (json['spaWomenItems'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      banner: Banner.fromJson(json['banner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HomeDataToJson(HomeData instance) => <String, dynamic>{
      'categories': instance.categories,
      'goToServices': instance.goToServices,
      'mostUsedServices': instance.mostUsedServices,
      'acRepairItems': instance.acRepairItems,
      'appliancesRepairItems': instance.appliancesRepairItems,
      'maleSpaItems': instance.maleSpaItems,
      'salonMenItems': instance.salonMenItems,
      'saloonWomenItems': instance.saloonWomenItems,
      'spaWomenItems': instance.spaWomenItems,
      'banner': instance.banner,
    };
