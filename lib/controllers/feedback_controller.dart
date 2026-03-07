// lib/controllers/feedback_controller.dart
import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import '../data/repository/feedback_repository.dart';
import '../models/feedback_req_model.dart';

class FeedbackController extends GetxController {
  final FeedbackRepository _repo;

  FeedbackController({FeedbackRepository? repo})
      : _repo = repo ?? FeedbackRepository();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // --- NETWORK HELPERS (Added) ---
  bool _isNetworkError(String msg) {
    final m = msg.toLowerCase();
    return m.contains('connectionerror') ||
        m.contains('connection timeout') ||
        m.contains('socketexception') ||
        m.contains('handshakeexception') ||
        m.contains('failed host lookup') ||
        m.contains('network is unreachable');
  }

  void _showNetworkErrorSnackbar() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Connection Error',
      'No internet connection. Please check your settings.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }

  /// Submits distinct feedback for Provider and Booking simultaneously
  Future<bool> submitAllFeedback({
    required String spId,
    required String bookingId,
    // Service Feedback
    required int serviceRating,
    required String serviceComment,
    // Provider Feedback
    required int providerRating,
    required String providerComment,
  }) async {
    isLoading.value = true;
    error.value = '';

    try {
      // 1. Create Request Models
      final spRequest = ServiceProviderRatingRequest(
        spId: spId,
        rating: providerRating,
        comment: providerComment,
      );

      final bookingRequest = ServiceBookingRatingRequest(
        bookingId: bookingId,
        rating: serviceRating,
        comment: serviceComment,
      );

      // 2. Call APIs Concurrently
      await Future.wait([
        if (spId.isNotEmpty) _repo.postServiceProviderRating(spRequest),
        if (bookingId.isNotEmpty) _repo.postServiceBookingRating(bookingRequest),
      ]);

      return true; // Success

    } catch (e) {
      final msg = e.toString();
      error.value = msg;
      print("Feedback Submission Error: $msg");

      // UPDATED: Check for network vs generic error
      if (_isNetworkError(msg)) {
        _showNetworkErrorSnackbar();
      } else {
        Get.snackbar(
          "Error",
          "Failed to submit feedback. Please try again.",
          snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
      return false; // Failed
    } finally {
      isLoading.value = false;
    }
  }
}