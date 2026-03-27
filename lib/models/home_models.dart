import 'package:json_annotation/json_annotation.dart';

part 'home_models.g.dart';

@JsonSerializable()
class ServiceCategory {
  final String title;
  final String icon;

  ServiceCategory({
    required this.title,
    required this.icon,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceCategoryToJson(this);
}

@JsonSerializable()
class GoToService {
  final String title;
  final String subtitle;
  final List<String> images;

  GoToService({
    required this.title,
    required this.subtitle,
    required this.images,
  });

  factory GoToService.fromJson(Map<String, dynamic> json) =>
      _$GoToServiceFromJson(json);

  Map<String, dynamic> toJson() => _$GoToServiceToJson(this);
}

@JsonSerializable()
class Service {
  final String image;
  final String title;
  final String? imagePath;
  final String? label;

  Service({
    required this.image,
    required this.title,
    this.imagePath,
    this.label,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}

@JsonSerializable()
class Banner {
  final String title;
  final String subtitle;
  final String image;

  Banner({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  factory Banner.fromJson(Map<String, dynamic> json) =>
      _$BannerFromJson(json);

  Map<String, dynamic> toJson() => _$BannerToJson(this);
}

@JsonSerializable()
class HomeData {
  final List<ServiceCategory> categories;
  final List<GoToService> goToServices;
  final List<Service> mostUsedServices;
  final List<Service> acRepairItems;
  final List<Service> appliancesRepairItems;
  final List<Service> maleSpaItems;
  final List<Service> salonMenItems;
  final List<Service> saloonWomenItems;
  final List<Service> spaWomenItems;
  final Banner banner;

  HomeData({
    required this.categories,
    required this.goToServices,
    required this.mostUsedServices,
    required this.acRepairItems,
    required this.appliancesRepairItems,
    required this.maleSpaItems,
    required this.salonMenItems,
    required this.saloonWomenItems,
    required this.spaWomenItems,
    required this.banner,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) =>
      _$HomeDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDataToJson(this);
}
