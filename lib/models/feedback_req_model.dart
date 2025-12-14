// lib/models/feedback_req_model.dart

class ServiceProviderRatingRequest {
  final String spId;
  final int rating;
  final String comment;

  ServiceProviderRatingRequest({
    required this.spId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      "spId": spId,
      "rating": rating,
      "comment": comment,
    };
  }
}

class ServiceBookingRatingRequest {
  final String bookingId;
  final int rating;
  final String comment;

  ServiceBookingRatingRequest({
    required this.bookingId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      "bookingId": bookingId,
      "rating": rating,
      "comment": comment,
    };
  }
}