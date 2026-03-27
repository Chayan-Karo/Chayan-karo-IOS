// lib/models/reschedule_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'reschedule_models.g.dart';

// =======================
// Request (unchanged)
// =======================
@JsonSerializable()
class RescheduleBookingRequest {
  final String bookingId;
  final String spId;
  final String addressId;
  final String bookingTime; // "HH:mm"
  final String bookingDate; // "yyyy-MM-dd"
  final String rescheduleReason;

  RescheduleBookingRequest({
    required this.bookingId,
    required this.spId,
    required this.addressId,
    required this.bookingTime,
    required this.bookingDate,
    required this.rescheduleReason,
  });

  factory RescheduleBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$RescheduleBookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RescheduleBookingRequestToJson(this);
}

// =======================
// Response envelope (UPDATED to match API)
// Example:
// {
//   "type": "Booking reschedule",
//   "result": {
//     "message": "Booking reschedule successfully.",
//     "bookingId": "86ca44b3-1417-4438-adb4-f69c21e455e4"
//   }
// }
// =======================
@JsonSerializable()
class RescheduleBookingEnvelope {
  final String? type;
  final RescheduleResult? result;

  RescheduleBookingEnvelope({this.type, this.result});

  // Convenience getters
  bool get success => (result?.bookingId ?? '').isNotEmpty;
  String get message => result?.message ?? '';
  String get bookingId => result?.bookingId ?? '';

  factory RescheduleBookingEnvelope.fromJson(Map<String, dynamic> json) =>
      _$RescheduleBookingEnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$RescheduleBookingEnvelopeToJson(this);
}

@JsonSerializable()
class RescheduleResult {
  final String message;
  final String bookingId;

  RescheduleResult({
    required this.message,
    required this.bookingId,
  });

  factory RescheduleResult.fromJson(Map<String, dynamic> json) =>
      _$RescheduleResultFromJson(json);
  Map<String, dynamic> toJson() => _$RescheduleResultToJson(this);
}
