class MostUsedServiceResponse {
  final String? type;
  final List<MostUsedService>? result;

  MostUsedServiceResponse({
    this.type,
    this.result,
  });

  factory MostUsedServiceResponse.fromJson(Map<String, dynamic> json) => MostUsedServiceResponse(
    type: json["type"],
    result: json["result"] == null 
        ? [] 
        : List<MostUsedService>.from(json["result"]!.map((x) => MostUsedService.fromJson(x))),
  );
}

class MostUsedService {
  final String? id;
  final String? categoryId;
  final String? name;
  final double? price;
  final String? description;
  final int? duration;
  final String? imgLink;
  final double? discountPercentage;
  final double? averageRating;
  final int? totalPerson;

  MostUsedService({
    this.id,
    this.categoryId,
    this.name,
    this.price,
    this.description,
    this.duration,
    this.imgLink,
    this.discountPercentage,
    this.averageRating,
    this.totalPerson,
  });

  factory MostUsedService.fromJson(Map<String, dynamic> json) => MostUsedService(
    id: json["id"],
    categoryId: json["categoryId"],
    name: json["name"],
    // Safe conversion for price, rating, discount
    price: (json["price"] as num?)?.toDouble(),
    description: json["description"],
    duration: json["duration"],
    imgLink: json["imgLink"],
    discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
    averageRating: (json["averageRating"] as num?)?.toDouble(),
    totalPerson: json["totalPerson"],
  );
}