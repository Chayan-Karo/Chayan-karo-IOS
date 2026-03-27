class ProviderServicesResponse {
  final String? type;
  final List<ProviderServiceItem>? result;

  ProviderServicesResponse({this.type, this.result});

  factory ProviderServicesResponse.fromJson(Map<String, dynamic> json) {
    return ProviderServicesResponse(
      type: json['type'],
      result: json['result'] != null
          ? (json['result'] as List)
              .map((i) => ProviderServiceItem.fromJson(i))
              .toList()
          : [],
    );
  }
}

class ProviderServiceItem {
  final String id;
  final String categoryId;
  final String serviceCategoryId;
  final String name;
  final double price;
  final String description;
  final int duration;
  final String? imgLink;
  final double discountPercentage;
  final double averageRating;
  final int totalPerson;

  // Add getter for formatted price if you use it in UI
  String get formattedPrice => "₹${price.toStringAsFixed(0)}";
  
  // Add getter for duration string if you use it in UI
// ✅ UPDATED GETTER: Converts minutes to "1 hr 30 mins" format
  String get formattedDuration {
    if (duration < 60) {
      return "$duration mins";
    } else {
      int hours = duration ~/ 60; // Integer division
      int minutes = duration % 60; // Remainder
      
      if (minutes == 0) {
        return "$hours hr${hours > 1 ? 's' : ''}";
      } else {
        return "$hours hr $minutes mins";
      }
    }
  }

  // Add getter for rating text if you use it in UI
  String get ratingText => averageRating > 0 ? averageRating.toStringAsFixed(1) : "New";

  ProviderServiceItem({
    required this.id,
    required this.categoryId,
    required this.serviceCategoryId,
    required this.name,
    required this.price,
    required this.description,
    required this.duration,
    this.imgLink,
    required this.discountPercentage,
    required this.averageRating,
    required this.totalPerson,
  });

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) {
    return ProviderServiceItem(
      id: json['id']?.toString() ?? "",
      categoryId: json['categoryId']?.toString() ?? "",
      serviceCategoryId: json['serviceCategoryId']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      price: (json['price'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? "",
      duration: (json['duration'] ?? 0).toInt(),
      imgLink: json['imgLink']?.toString(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalPerson: (json['totalPerson'] ?? 0).toInt(),
    );
  }
}