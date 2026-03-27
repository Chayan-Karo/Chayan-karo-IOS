import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_snackbar.dart';

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
final RxBool isRefunding = false.obs;
  final RxBool isPlacing = false.obs;
  final RxString error = ''.obs;
// --- NEW: Network Error Helpers ---
  bool _isNetworkError(String msg) {
    final m = msg.toLowerCase();
    return m.contains('connectionerror') ||
        m.contains('connection timeout') ||
        m.contains('socketexception') ||
        m.contains('failed host lookup') ||
        m.contains('network is unreachable');
  }

  void _showNetworkErrorSnackbar() {
    AppSnackbar.showError('No internet connection or server is unreachable. Please check your settings.');
  }

  void _showErrorSnackbar(String title, String message) {
    AppSnackbar.showError(message.replaceFirst('Exception: ', ''));
  }
 // lib/controllers/booking_controller.dart

Future<AddBookingResponse> placeBooking({
  required String spId,
  required String addressId,
  required DateTime slot,
  required String paymentMode,
  required List<BookingServiceItem> services,
  required num actualAmount,   // <--- Added
  required num plateFormFee,  // <--- Added
  required num gstAmount,      // <--- Added
  required num gstPercentage,  // <--- Added
  required int totalDuration,
  String? couponId,
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
      couponId: couponId,
      bookingService: services,
      bookingAmount: BookingAmount( // <--- Constructing the new object
        actualAmount: actualAmount,
        plateFormFee: plateFormFee,
        gstAmount: gstAmount,
        gstPercentage: gstPercentage,
      ),
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

      // 1. CHECK FOR NETWORK ERROR (New)
      if (_isNetworkError(msg)) {
      //  _showNetworkErrorSnackbar();
        // Return a safe error response so UI doesn't crash
        return AddBookingResponse(
          type: 'Error',
          result: AddBookingResult(
            message: 'Network error. Please check your internet connection.',
            bookingId: null,
          ),
        );
      }

      // 2. CHECK FOR LOGIC ERRORS (Already Booked)
      final isAlready =
          msg.contains('Booking all ready exist') ||
          msg.contains('already exist') ||
          msg.contains('already booked');

      if (isAlready) {
        return AddBookingResponse(
          type: 'Error',
          result: AddBookingResult(
            message:
                'This provider is already booked for this time slot. Please choose another slot or provider.',
            bookingId: null,
          ),
        );
      }

      // 3. GENERIC ERROR
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
    required num actualAmount,   // <--- ADDED
    required num plateFormFee,  // <--- ADDED
    required num gstAmount,      // <--- ADDED
    required num gstPercentage,  // <--- ADDED
    String? couponId,            // Added for completeness
  }) async {
    final res = await placeBooking(
      spId: spId,
      addressId: addressId,
      slot: slot,
      paymentMode: 'ONLINE',
      services: services,
      totalDuration: totalDuration,
      actualAmount: actualAmount,     // <--- PASSING NEW PARAMETERS
      plateFormFee: plateFormFee,
      gstAmount: gstAmount,
      gstPercentage: gstPercentage,
      couponId: couponId,
      
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
        AppSnackbar.showError(error.value);
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
        AppSnackbar.showError(error.value);
      }

      return ok;
    } catch (e) {
final msg = e.toString();
      error.value = msg;      
      // UPDATED: Check for network error specific to reschedule
      if (_isNetworkError(msg)) {
        _showNetworkErrorSnackbar();
      } else {
        _showErrorSnackbar('Reschedule Failed', msg);
      }
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
        AppSnackbar.showError(error.value);
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
        AppSnackbar.showError(error.value);
      }

      return ok;
    } catch (e) {
      final msg = e.toString();
      error.value = msg;

      // UPDATED: Check for network error specific to cancel
      if (_isNetworkError(msg)) {
        _showNetworkErrorSnackbar();
      } else {
        _showErrorSnackbar('Cancellation Failed', msg);
      }
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
  // 2. Add the refund method
Future<bool> processRefund({
  required String bookingId,
  required String refundBankId,
}) async {
  try {
    isRefunding.value = true;
    
    final payload = {
      "bookingId": bookingId.trim(),
      "refundBankId": refundBankId.trim(),
    };

    await _repo.refundBookingAmount(payload);
    return true;
  } catch (e) {
    final msg = e.toString();
    // Handle errors similar to cancel/reschedule
    if (_isNetworkError(msg)) {
      _showNetworkErrorSnackbar();
    } else {
      _showErrorSnackbar('Refund Failed', 'We couldn\'t process your refund request. Please contact support.');
    }
    return false;
  } finally {
    isRefunding.value = false;
  }
}
}
