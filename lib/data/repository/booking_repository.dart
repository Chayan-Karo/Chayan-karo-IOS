// lib/data/repository/booking_repository.dart
import 'package:flutter/foundation.dart';

import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/booking_models.dart';
import '../../models/reschedule_models.dart';
import '../../models/cancel_models.dart';

class BookingRepository {
  BookingRepository({AppDatabase? database})
      : _db = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final AppDatabase _db;
  final ApiService _api;

  Future<AddBookingResponse> addBooking(AddBookingRequest req) async {
    final token = await _db.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final body = req.toJson();

    assert(body['bookingService'] is List, 'bookingService must be a List');
    if (kDebugMode) debugPrint('AddBooking final => $body');

    try {
      // This may throw when backend sends: { type:"Error", result:"Booking all ready exist." }
      final res = await _api.addBookingRaw('Bearer $token', body);
      return res;
    } catch (e) {
      final msg = e.toString();

      // If the error is our String/Map cast, convert to a clean, user-facing message.
      if (msg.contains("type 'String' is not a subtype of type 'Map<String, dynamic>'")) {
        // Backend message is "Booking all ready exist."
        throw Exception('Booking all ready exist.');
      }

      // Pass through other errors
      rethrow;
    }
  }

  // reschedule / cancel unchanged...
  Future<RescheduleBookingEnvelope> rescheduleBooking(
    RescheduleBookingRequest req,
  ) async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final body = req.toJson();
    if (kDebugMode) debugPrint('RescheduleBooking final => $body');

    return _api.rescheduleBookingRaw('Bearer $token', body);
  }

  Future<RescheduleBookingEnvelope> rescheduleBookingFromMap(
    Map<String, dynamic> payload,
  ) async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    if (kDebugMode) debugPrint('RescheduleBooking (map) => $payload');

    return _api.rescheduleBookingRaw('Bearer $token', payload);
  }

  Future<CancelBookingEnvelope> cancelBooking(
    CancelBookingRequest req,
  ) async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    final body = req.toJson();
    if (kDebugMode) debugPrint('CancelBooking final => $body');

    return _api.cancelBookingRaw('Bearer $token', body);
  }

  Future<CancelBookingEnvelope> cancelBookingFromMap(
    Map<String, dynamic> payload,
  ) async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    if (kDebugMode) debugPrint('CancelBooking (map) => $payload');

    return _api.cancelBookingRaw('Bearer $token', payload);
  }
  Future<void> refundBookingAmount(Map<String, dynamic> payload) async {
  final token = await _db.getAuthToken();
  if (token == null) throw Exception('User not authenticated');

  if (kDebugMode) debugPrint('RefundBooking final => $payload');

  // This calls the @POST('/user/refundBookingAmount') you added to ApiService
  return _api.refundBookingAmount('Bearer $token', payload);
}
}
