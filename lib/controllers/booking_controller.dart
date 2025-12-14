// lib/controllers/booking_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repository/booking_repository.dart';
import '../models/booking_models.dart';
import '../models/reschedule_models.dart';
import '../models/cancel_models.dart';

// ADD: imports to trigger background refresh safely
import 'dart:async' show unawaited;            // for fire-and-forget
import 'booking_read_controller.dart';         // to find and refresh the list

class BookingController extends GetxController {
  final BookingRepository _repo;
  BookingController({BookingRepository? repo}) : _repo = repo ?? BookingRepository();

  final RxBool isPlacing = false.obs;
  final RxString error = ''.obs;

 // lib/controllers/booking_controller.dart

Future<AddBookingResponse> placeBooking({
  required String spId,
  required String addressId,
  required DateTime slot,
  required String paymentMode,
  required List<BookingServiceItem> services,
  required int totalDuration,
}) async {
  try {
    isPlacing.value = true;
    error.value = '';

    final bookingDate =
        "${slot.year.toString().padLeft(4, '0')}-${slot.month.toString().padLeft(2, '0')}-${slot.day.toString().padLeft(2, '0')}";
    // OLD
// "${slot.hour.toString().padLeft(2, '0')}${slot.minute.toString().padLeft(2, '0')}";

// NEW
    final bookingTime =
         "${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}";

    final req = AddBookingRequest(
      spId: spId,
      totalDuration: totalDuration,
      addressId: addressId,
      bookingTime: bookingTime,
      bookingDate: bookingDate,
      paymentMode: paymentMode,
      bookingService: services,
    );

    final res = await _repo.addBooking(req);

    try {
      final readCtrl = Get.find<BookingReadController>();
      unawaited(readCtrl.fetchCustomerBookings());
    } catch (_) {}

    return res;
  } catch (e) {
    final msg = e.toString();
    error.value = msg;

    final isAlready =
        msg.contains('Booking all ready exist') ||
        msg.contains('already exist') ||
        msg.contains('already booked');

    // DO NOT show any snackbar here.
    // Just return a response object and let the UI decide.

    if (isAlready) {
      // Normalized friendly message that UI will use
      return AddBookingResponse(
        type: 'Error',
        result: AddBookingResult(
          message:
              'This provider is already booked for this time slot. Please choose another slot or provider.',
          bookingId: null,
        ),
      );
    }

    // Other errors: generic message for UI
    return AddBookingResponse(
      type: 'Error',
      result: AddBookingResult(
        message: msg.replaceFirst('Exception: ', ''),
        bookingId: null,
      ),
    );
  } finally {
    isPlacing.value = false;
  }
}


  // Helper for ONLINE flow: returns bookingId directly
  Future<String> placeOnlineBookingAndGetId({
    required String spId,
    required String addressId,
    required DateTime slot,
    required List<BookingServiceItem> services,
    required int totalDuration,
  }) async {
    final res = await placeBooking(
      spId: spId,
      addressId: addressId,
      slot: slot,
      paymentMode: 'ONLINE',
      services: services,
      totalDuration: totalDuration,
    );

    // If placeBooking threw, this is never reached; if we are here, we have a response.
    if (!(res.success) || (res.bookingId ?? '').isEmpty) {
      final msg =
          res.message.isNotEmpty ? res.message : 'Failed to create online booking';
      throw Exception(msg);
    }

    return res.bookingId!;
  }

  // =========================
  // RESCHEDULE FLOW
  // =========================

  final RxBool isRescheduling = false.obs;

  // Map-friendly entry point used by UI
  // Expected keys: bookingId, spId, addressId, bookingDate (yyyy-MM-dd),
  // bookingTime (HHmm), rescheduleReason
  Future<bool> rescheduleBooking(Map<String, dynamic> payload) async {
    try {
      isRescheduling.value = true;
      error.value = '';

      // Basic validations to surface early UI mistakes
      final bookingId = (payload['bookingId'] ?? '').toString();
      final spId = (payload['spId'] ?? '').toString();
      final addressId = (payload['addressId'] ?? '').toString();
      final bookingDate = (payload['bookingDate'] ?? '').toString();
      final bookingTime = (payload['bookingTime'] ?? '').toString();
      final rescheduleReason = (payload['rescheduleReason'] ?? '').toString();

      if (bookingId.isEmpty ||
          spId.isEmpty ||
          addressId.isEmpty ||
          bookingDate.isEmpty ||
          bookingTime.isEmpty) {
        error.value = 'Missing required fields for reschedule';
        Get.snackbar(
          'Reschedule failed',
          error.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      final req = RescheduleBookingRequest(
        bookingId: bookingId,
        spId: spId,
        addressId: addressId,
        bookingDate: bookingDate,   // expects YYYY-MM-DD
        bookingTime: bookingTime,   // expects HHmm string
        rescheduleReason:
            rescheduleReason.isEmpty ? 'Change of time' : rescheduleReason,
      );

      // repository returns envelope
      final RescheduleBookingEnvelope res = await _repo.rescheduleBooking(req);
      final bool ok = res.success;

      // Background refresh
      if (ok) {
        try {
          final readCtrl = Get.find<BookingReadController>();
          unawaited(readCtrl.fetchCustomerBookings());
        } catch (_) {}
      } else {
        error.value = res.message.isNotEmpty ? res.message : 'Failed to reschedule';
        Get.snackbar(
          'Reschedule failed',
          error.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }

      return ok;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Reschedule failed',
        error.value.replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isRescheduling.value = false;
    }
  }

  // Optional typed helper if UI passes DateTime preferred instead of strings
  Future<bool> rescheduleBookingTyped({
    required String bookingId,
    required String spId,
    required String addressId,
    required DateTime preferred,
    String rescheduleReason = 'Change of time',
  }) async {
    // FORMAT: date YYYY-MM-DD
    final bookingDate =
        "${preferred.year.toString().padLeft(4, '0')}-${preferred.month.toString().padLeft(2, '0')}-${preferred.day.toString().padLeft(2, '0')}";

    // TIME: HHmm string
    // OLD
// "${preferred.hour.toString().padLeft(2, '0')}${preferred.minute.toString().padLeft(2, '0')}";

// NEW
    final bookingTime =
         "${preferred.hour.toString().padLeft(2, '0')}:${preferred.minute.toString().padLeft(2, '0')}";
         
    return rescheduleBooking({
      'bookingId': bookingId,
      'spId': spId,
      'addressId': addressId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'rescheduleReason': rescheduleReason,
    });
  }

  // =========================
  // CANCEL FLOW
  // =========================

  final RxBool isCancelling = false.obs;

  Future<bool> cancelBooking({
    required String bookingId,
    String reason = 'Change of plan',
  }) async {
    try {
      isCancelling.value = true;
      error.value = '';

      if (bookingId.trim().isEmpty) {
        error.value = 'Missing bookingId';
        Get.snackbar(
          'Cancel failed',
          error.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }

      // repository returns envelope
      final CancelBookingEnvelope res = await _repo.cancelBookingFromMap({
        'bookingId': bookingId.trim(),
        'reason': reason.trim().isEmpty ? 'Change of plan' : reason.trim(),
      });

      final bool ok = res.success;

      // Background refresh
      if (ok) {
        try {
          final readCtrl = Get.find<BookingReadController>();
          unawaited(readCtrl.fetchCustomerBookings());
        } catch (_) {}
      } else {
        error.value = res.message.isNotEmpty ? res.message : 'Failed to cancel booking';
        Get.snackbar(
          'Cancel failed',
          error.value,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }

      return ok;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Cancel failed',
        error.value.replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isCancelling.value = false;
    }
  }

  // Optional typed variant
  Future<bool> cancelBookingTyped({
    required String bookingId,
    required String reason,
  }) async {
    return cancelBooking(bookingId: bookingId, reason: reason);
  }
}
