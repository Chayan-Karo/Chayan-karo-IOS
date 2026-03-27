import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../local/database.dart';
import '../../models/provider_service_model.dart'; // Ensure this path matches your model

@immutable
class SaathiServiceRepository {
  SaathiServiceRepository({
    AppDatabase? database,
  })  : _database = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final ApiService _api;
  final AppDatabase _database;

  Future<List<ProviderServiceItem>> getServices(String providerId) async {
    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      // calling the endpoint defined in your ApiService
      final response = await _api.getServicesByProviderId(
        'Bearer $token',
        providerId, 
      );
      
      // Return the list directly, handling nulls if necessary
      return response.result ?? [];
      
    } catch (e) {
      // Handle 404 or empty states gracefully if needed
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
  Future<bool> checkAvailability({
    required String providerId,
    required String addressId,
    required String bookingDate, // yyyy-MM-dd
    required String bookingTime, // HH:mm
    required int duration,
  }) async {
    final token = await _database.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      final body = {
        "providerId": providerId,
        "addressId": addressId,
        "bookingDate": bookingDate,
        "bookingTime": bookingTime,
        "currentBookingDuration": duration
      };

      final response = await _api.checkServiceProviderAvailability('Bearer $token', body);
      return response.isAvailable;
    } catch (e) {
      if (e is DioException) {
        // If the API returns 400/404 for unavailability, throw the error message
        final msg = e.response?.data['result'] ?? e.message;
        throw Exception(msg);
      }
      rethrow;
    }
  }
}