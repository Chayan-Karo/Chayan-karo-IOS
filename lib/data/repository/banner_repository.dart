import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/banner_model.dart';

class BannerRepository {
  final AppDatabase _db = AppDatabase();
  final _api = NetworkClient().apiService;

  Future<List<BannerItem>> getHomeBanners() async {
    final token = await _db.getAuthToken();
    final authHeader = (token != null && token.isNotEmpty) ? 'Bearer $token' : null;

    try {
      // You should add this method to your ApiService interface
      final response = await _api.getHomeBanners(authHeader);
      return response.result ?? [];
    } catch (e) {
      rethrow;
    }
  }
}