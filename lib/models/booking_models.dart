// lib/models/booking_models.dart
import 'package:json_annotation/json_annotation.dart';
part 'booking_models.g.dart';

@JsonSerializable()
class BookingServiceItem {
  final String categoryId;
  final String serviceId;
  final int discountPercentage;
  final num price;
  final num discountPrice;
  final int quantity;


  BookingServiceItem({
    required this.categoryId,
    required this.serviceId,
    required this.discountPercentage,
    required this.price,
    required this.discountPrice,
    required this.quantity,

  });

  factory BookingServiceItem.fromJson(Map<String, dynamic> json) => _$BookingServiceItemFromJson(json);
  Map<String, dynamic> toJson() => _$BookingServiceItemToJson(this);
}
@JsonSerializable()
class BookingAmount {
  final num actualAmount;
  final num plateFormFee;
  final num gstAmount;
  final num gstPercentage;

  BookingAmount({
    required this.actualAmount,
    required this.plateFormFee,
    required this.gstAmount,
    required this.gstPercentage,
  });

  factory BookingAmount.fromJson(Map<String, dynamic> json) => _$BookingAmountFromJson(json);
  Map<String, dynamic> toJson() => _$BookingAmountToJson(this);
}

@JsonSerializable()
class AddBookingRequest {
  final String spId;
  final int totalDuration;
  final String addressId;
  final String bookingTime;  // "HH:mm"
  final String bookingDate;  // "yyyy-MM-dd"
  final String paymentMode;  // "CASH" | "ONLINE"
  final String? couponId; // ✅ Nullable couponId
  final BookingAmount bookingAmount; // <--- NEW FIELD
  final List<BookingServiceItem> bookingService;

  AddBookingRequest({
    required this.spId,
    required this.totalDuration,
    required this.addressId,
    required this.bookingTime,
    required this.bookingDate,
    required this.paymentMode,
    this.couponId,
    required this.bookingAmount, // <--- NEW FIELD
    required this.bookingService,
  });

  factory AddBookingRequest.fromJson(Map<String, dynamic> json) => _$AddBookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddBookingRequestToJson(this);
}

/*
Backend response observed in logs:
{
  "type": "Booking",
  "result": {
    "message": "Booking completed successfully.",
    "bookingId": "50078ac5-40e4-4927-b0a8-7b8ca678efb2"
  }
}
This wrapper parses that structure and exposes convenient getters.
*/

@JsonSerializable()
class AddBookingResponse {
  final String? type;
  final AddBookingResult? result;

  AddBookingResponse({this.type, this.result});

  // Convenience getters so existing UI/controller can use .success/.message/.bookingId
  bool get success => (result?.bookingId?.isNotEmpty ?? false);
  String get message => result?.message ?? '';
  String? get bookingId => result?.bookingId;

  factory AddBookingResponse.fromJson(Map<String, dynamic> json) => _$AddBookingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AddBookingResponseToJson(this);
}

@JsonSerializable()
class AddBookingResult {
  final String? message;
  final String? bookingId;

  AddBookingResult({this.message, this.bookingId});

  factory AddBookingResult.fromJson(Map<String, dynamic> json) => _$AddBookingResultFromJson(json);
  Map<String, dynamic> toJson() => _$AddBookingResultToJson(this);
}
