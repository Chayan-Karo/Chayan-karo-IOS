import 'package:meta/meta.dart';
import 'package:get/get.dart';
import '../remote/api_service.dart';
import '../remote/network_client.dart';
import '../local/database.dart';
import '../../models/payment_models.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';

@immutable
class PaymentRepository {
  PaymentRepository();

  ApiService get _api => NetworkClient().apiService; // use singleton
  AppDatabase get _database => Get.find<AppDatabase>(); // like ProfileRepository

  final _uuid = const Uuid();
  final _random = Random.secure();

  /// Create order on backend (server handles Razorpay order creation)
  Future<RazorpayOrderDetails> createOrder({
    required double amount,
    required String bookingId,
  }) async {
    try {
      final receipt = _generateUniqueReceipt();
      final token = await _database.getAuthToken();

      print('🔍 Payment Repository Debug:');
      print('   Token retrieved: ${token?.substring(0, 20) ?? 'null'}...');
      print('   Receipt: $receipt');
      print('   BookingId: $bookingId');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login again.');
      }

      final request = CreateOrderRequest(
        amount: amount,
        receipt: receipt,
        bookingId: bookingId,
      );

      final response = await _api.createOrder('Bearer $token', request);

      final orderDetails = response.getOrderDetails();
      if (orderDetails == null) {
        throw Exception('Failed to parse order details');
      }

      print('✅ Order created successfully:');
      print('   Order ID: ${orderDetails.id}');
      print('   Amount: ${orderDetails.amount}');
      print('   Receipt: ${orderDetails.receipt}');

      return orderDetails;
    } catch (e) {
      print('❌ PaymentRepository Error: $e');
      throw Exception('Error creating order: $e');
    }
  }

  /// Persist verified payment against booking on your backend
  Future<dynamic> updatePayment({
    required String bookingId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final token = await _database.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final body = {
      'bookingId': bookingId,
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    };

    print('💾 Posting payment update => $body');
    return await _api.updatePayment('Bearer $token', body);
  }

  /// Generate unique receipt ID (max 40 characters for Razorpay)
  String _generateUniqueReceipt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _generateRandomString(8);
    return 'RCPT_${timestamp}_$randomSuffix';
  }

  /// Generate random alphanumeric string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }
}
