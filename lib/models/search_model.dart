class SearchResponse {
  final String? type;
  final List<SearchResult>? result;

  SearchResponse({
    this.type,
    this.result,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
    type: json["type"],
    result: json["result"] == null ? [] : List<SearchResult>.from(json["result"]!.map((x) => SearchResult.fromJson(x))),
  );
}

class SearchResult {
  final String? id;
  final String? categoryId;
  final String? name;
  final double? price;              // Changed from int? to double?
  final String? description;
  final int? duration;
  final String? imgLink;
  final double? discountPercentage; // Changed from int? to double?
  final double? averageRating;      // Changed from int? to double?
  final int? totalPerson;

  SearchResult({
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

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    id: json["id"],
    categoryId: json["categoryId"],
    name: json["name"],
    // FIX: Use (json["key"] as num?)?.toDouble() to safely handle int (8099) or double (8099.0)
    price: (json["price"] as num?)?.toDouble(),
    description: json["description"],
    duration: json["duration"],
    imgLink: json["imgLink"],
    // FIX: Safely parse discountPercentage and averageRating
    discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
    averageRating: (json["averageRating"] as num?)?.toDouble(),
    totalPerson: json["totalPerson"],
  );
}