class BookedSaathiResponse {
  final String? type;
  final List<BookedSaathiItem> result;

  BookedSaathiResponse({this.type, required this.result});

  factory BookedSaathiResponse.fromJson(Map<String, dynamic> json) {
    return BookedSaathiResponse(
      type: json['type'],
      result: json['result'] == null
          ? []
          : (json['result'] as List)
              .map((e) => BookedSaathiItem.fromJson(e))
              .toList(),
    );
  }
}

class BookedSaathiItem {
  final String id;
  final String firstName;
  final String? middleName;
  final String? lastName;
  final String mobileNo;
  final num averageRating; // Handles both int and double
  final int totalReview;
  final String? imgLink;
  final bool isLocked;

  BookedSaathiItem({
    required this.id,
    required this.firstName,
    this.middleName,
    this.lastName,
    required this.mobileNo,
    this.averageRating = 0,
    this.totalReview = 0,
    this.imgLink,
    this.isLocked = false,
  });

  // Helper to get full name
  String get fullName {
    final first = firstName.trim();
    final last = lastName?.trim() ?? '';
    return "$first $last".trim();
  }

  factory BookedSaathiItem.fromJson(Map<String, dynamic> json) {
    return BookedSaathiItem(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'],
      mobileNo: json['mobileNo'] ?? '',
      averageRating: json['averageRating'] ?? 0,
      totalReview: json['totalReview'] ?? 0,
      imgLink: json['imgLink'],
      isLocked: json['isLocked'] ?? false,
    );
  }
  
  // Convert to Map for passing back to previous screen if needed
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": fullName,
      "image": imgLink ?? "",
      "rating": averageRating,
      "jobs": totalReview,
    };
  }
}