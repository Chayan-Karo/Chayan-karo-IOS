import '../remote/network_client.dart';
import '../../data/local/database.dart';
import '../../models/banner_model.dart';

class BannerRepository {
  final AppDatabase _db = AppDatabase();
  final _api = NetworkClient().apiService;

  Future<List<BannerItem>> getHomeBanners() async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('Authentication Required');

    try {
      // You should add this method to your ApiService interface
      final response = await _api.getHomeBanners('Bearer $token');
      return response.result ?? [];
    } catch (e) {
      rethrow;
    }
  }
}