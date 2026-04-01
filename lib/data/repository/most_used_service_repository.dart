import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/most_used_service_model.dart';

class MostUsedServiceRepository {
  // Initialize DB and API Service
  MostUsedServiceRepository({AppDatabase? database})
      : _db = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final AppDatabase _db;
  final ApiService _api;

  Future<List<MostUsedService>> fetchMostUsedServices() async {
    // 1. Get Token from DB
    final token = await _db.getAuthToken();
    final authHeader = (token != null && token.isNotEmpty) ? 'Bearer $token' : null;
    try {
      // 2. Call API with Bearer token
      final response = await _api.getMostUsedServices(authHeader);
      return response.result ?? [];
    } catch (e) {
      rethrow;
    }
  }
}