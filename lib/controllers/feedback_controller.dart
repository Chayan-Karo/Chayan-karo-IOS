// lib/controllers/feedback_controller.dart
import 'package:get/get.dart';
import '../data/repository/feedback_repository.dart';
import '../models/feedback_req_model.dart';
import '../widgets/app_snackbar.dart';

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
    AppSnackbar.showError('No internet connection. Please check your settings.');
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
        AppSnackbar.showError('Failed to submit feedback. Please try again.');
      }
      return false; // Failed
    } finally {
      isLoading.value = false;
    }
  }
}