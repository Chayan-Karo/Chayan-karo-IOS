// lib/models/cancel_models.dart
import 'package:json_annotation/json_annotation.dart';

part 'cancel_models.g.dart';

// =======================
// Request (unchanged)
// =======================
@JsonSerializable()
class CancelBookingRequest {
  final String bookingId;
  final String reason;

  CancelBookingRequest({
    required this.bookingId,
    required this.reason,
  });

  factory CancelBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CancelBookingRequestToJson(this);
}

// =======================
// Response envelope (UPDATED to match API)
// Expected shape (analogous to reschedule):
// {
//   "type": "Booking cancel",
//   "result": {
//     "message": "Booking cancelled successfully.",
//     "bookingId": "86ca44b3-1417-4438-adb4-f69c21e455e4"
//   }
// }
// =======================
@JsonSerializable()
class CancelBookingEnvelope {
  final String? type;
  final CancelResult? result;

  CancelBookingEnvelope({this.type, this.result});

  // Convenience getters
  bool get success => (result?.bookingId ?? '').isNotEmpty;
  String get message => result?.message ?? '';
  String get bookingId => result?.bookingId ?? '';

  factory CancelBookingEnvelope.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingEnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$CancelBookingEnvelopeToJson(this);
}

@JsonSerializable()
class CancelResult {
  final String message;
  final String bookingId;

  CancelResult({
    required this.message,
    required this.bookingId,
  });

  factory CancelResult.fromJson(Map<String, dynamic> json) =>
      _$CancelResultFromJson(json);
  Map<String, dynamic> toJson() => _$CancelResultToJson(this);
}
