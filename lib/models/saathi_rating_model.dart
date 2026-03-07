class RatingResponse {
  final String? type;
  final List<ProviderRatingItem> result;

  RatingResponse({this.type, required this.result});

  factory RatingResponse.fromJson(Map<String, dynamic> json) {
    return RatingResponse(
      type: json['type'],
      result: json['result'] == null
          ? []
          : (json['result'] as List)
              .map((e) => ProviderRatingItem.fromJson(e))
              .toList(),
    );
  }
}

class ProviderRatingItem {
  final String customerName;
  final String customerImage;
  final String comment;
  final num rating; // Use num to handle both int and double

  ProviderRatingItem({
    required this.customerName,
    required this.customerImage,
    required this.comment,
    required this.rating,
  });

  factory ProviderRatingItem.fromJson(Map<String, dynamic> json) {
    return ProviderRatingItem(
      customerName: json['customerName'] ?? 'Unknown User',
      customerImage: json['customerImage'] ?? '',
      comment: json['comment'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}