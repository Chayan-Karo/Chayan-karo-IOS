// lib/controllers/feedback_controller.dart
import 'package:flutter/material.dart'; // Added for Colors
import 'package:get/get.dart';
import '../data/repository/feedback_repository.dart';
import '../models/feedback_req_model.dart';

class FeedbackController extends GetxController {
  final FeedbackRepository _repo;

  FeedbackController({FeedbackRepository? repo})
      : _repo = repo ?? FeedbackRepository();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// Submits distinct feedback for Provider and Booking simultaneously
  Future<bool> submitAllFeedback({
    required String spId,
    required String bookingId,
    // Removed required String serviceId
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
        // Removed serviceId: serviceId,
        rating: serviceRating,
        comment: serviceComment,
      );

      // 2. Call APIs Concurrently
      await Future.wait([
        if (spId.isNotEmpty) _repo.postServiceProviderRating(spRequest),
        // Removed serviceId.isNotEmpty check
        if (bookingId.isNotEmpty) _repo.postServiceBookingRating(bookingRequest),
      ]);

      return true; // Success

    } catch (e) {
      error.value = e.toString();
      print("Feedback Submission Error: $e");
      Get.snackbar(
        "Error", 
        "Failed to submit feedback. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false; // Failed
    } finally {
      isLoading.value = false;
    }
  }
}