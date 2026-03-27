import 'package:meta/meta.dart';
import 'package:dio/dio.dart';
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../local/database.dart';
import '../../models/booked_saathi_model.dart';

@immutable
class BookedSaathiRepository {
  BookedSaathiRepository({
    AppDatabase? database,
  })  : _database = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final ApiService _api;
  final AppDatabase _database;

  Future<List<BookedSaathiItem>> getBookedProviders() async {
    final token = await _database.getAuthToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _api.getBookedServiceProviders(
        'Bearer $token',
      );
      return response.result;
    } catch (e) {
      // Return empty list on 404 or other known empty states if preferred
      if (e is DioException && e.response?.statusCode == 404) {
        return [];
      }
      rethrow;
    }
  }
}