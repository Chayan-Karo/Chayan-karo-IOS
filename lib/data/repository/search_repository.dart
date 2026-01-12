import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../data/local/database.dart'; // Adjust path to your database
import '../../models/search_model.dart'; // Import the model created below

class SearchRepository {
  // Initialize DB and API Service following your pattern
  SearchRepository({AppDatabase? database})
      : _db = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final AppDatabase _db;
  final ApiService _api;

  Future<List<SearchResult>> searchServices(String query) async {
    // 1. Get Token from DB
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('User not authenticated');

    try {
      // 2. Call API with Bearer token
      // Note: The response model wraps the list in a 'result' field
      final response = await _api.searchActiveServices('Bearer $token', query);
      return response.result ?? [];
    } catch (e) {
      // Handle or rethrow error
      rethrow;
    }
  }
}