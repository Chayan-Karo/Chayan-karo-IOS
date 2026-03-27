// lib/data/repository/feedback_repository.dart
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/feedback_req_model.dart';

class FeedbackRepository {
  // 1. Initialize DB and API Service like your other repos
  FeedbackRepository({AppDatabase? database})
      : _db = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final AppDatabase _db;
  final ApiService _api;

  /// Posts rating for the Service Provider
  Future<void> postServiceProviderRating(ServiceProviderRatingRequest request) async {
    // 2. Get Token
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    // 3. Call API with Bearer token
    await _api.rateServiceProvider('Bearer $token', request);
  }

  /// Posts rating for the specific Service/Booking
  Future<void> postServiceBookingRating(ServiceBookingRatingRequest request) async {
    // 2. Get Token
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    // 3. Call API with Bearer token
    await _api.rateServiceBooking('Bearer $token', request);
  }
}