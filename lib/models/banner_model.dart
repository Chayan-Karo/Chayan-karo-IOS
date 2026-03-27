class BannerResponse {
  final String? type;
  final List<BannerItem>? result;

  BannerResponse({this.type, this.result});

  factory BannerResponse.fromJson(Map<String, dynamic> json) => BannerResponse(
        type: json["type"],
        result: json["result"] == null
            ? null
            : List<BannerItem>.from(json["result"].map((x) => BannerItem.fromJson(x))),
      );
}

class BannerItem {
  final String? id;
  final String? description;
  final String? bannerUrl;
  final bool? isActive;
  final Category? category;
  // NEW FIELD
  final ServiceCategory? serviceCategory;

  BannerItem({
    this.id,
    this.description,
    this.bannerUrl,
    this.isActive,
    this.category,
    this.serviceCategory,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) => BannerItem(
        id: json["id"],
        description: json["description"],
        bannerUrl: json["bannerUrl"],
        isActive: json["isActive"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        // NEW PARSING LOGIC
        serviceCategory: json["serviceCategory"] == null 
            ? null 
            : ServiceCategory.fromJson(json["serviceCategory"]),
      );
}

class Category {
  final String? id;
  final String? name;

  Category({this.id, this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );
}

// NEW CLASS
class ServiceCategory {
  final String? id;
  final String? name;

  ServiceCategory({this.id, this.name});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) => ServiceCategory(
        id: json["id"],
        name: json["name"],
      );
}