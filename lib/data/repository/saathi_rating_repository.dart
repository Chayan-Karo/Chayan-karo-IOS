import 'package:meta/meta.dart';
import 'package:dio/dio.dart'; // Import Dio to handle 404 exceptions
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../local/database.dart';
import '../../models/saathi_rating_model.dart';

@immutable
class SaathiRatingRepository {
  SaathiRatingRepository({
    AppDatabase? database,
  })  : _database = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final ApiService _api;
  final AppDatabase _database;

  Future<List<ProviderRatingItem>> getRatings(String serviceProviderId) async {
    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _api.getProviderRatings(
        'Bearer $token',
        serviceProviderId,
      );
      return response.result;
    } on DioException catch (e) {
      // --- FIX START: Handle 404 Not Found ---
      if (e.response?.statusCode == 404) {
        // If API says 404 (Not Found), it means there are 0 ratings.
        // Return an empty list so the UI shows the "No reviews" state.
        return [];
      }
      // --- FIX END ---
      
      // For other errors (500, no internet), rethrow them to be handled by controller
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}