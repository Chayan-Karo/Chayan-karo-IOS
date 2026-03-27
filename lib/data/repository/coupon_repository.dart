import '../../data/local/database.dart';
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../../models/coupon_models.dart';

class CouponRepository {
  CouponRepository({AppDatabase? database})
      : _db = database ?? AppDatabase(),
        _api = NetworkClient().apiService;

  final AppDatabase _db;
  final ApiService _api;

  Future<List<Coupon>> getCoupons(String categoryId) async {
    final token = await _db.getAuthToken();
    if (token == null) throw Exception('Auth Required');

    final response = await _api.getAllCoupons('Bearer $token', categoryId);
    return response.result ?? [];
  }

  Future<bool> validateCoupon({
    required String categoryId,
    required String couponId,
    required String code,
    required double total,
  }) async {
    final token = await _db.getAuthToken();
    if (token == null) return false;

    try {
      final body = {
        "categoryId": categoryId,
        "couponId": couponId,
        "couponCode": code,
        "totalAmount": total
      };
      // Note: Assuming your ValidateCouponResponse has a success boolean
      final response = await _api.validateCoupon('Bearer $token', body);
     return response.isValid;
    } catch (e) {
      return false;
    }
  }
}