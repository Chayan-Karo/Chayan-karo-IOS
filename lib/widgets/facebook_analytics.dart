import 'package:facebook_app_events/facebook_app_events.dart';

class FBAnalytics {
  static final _fb = FacebookAppEvents();

  // 1. Log when user completes Login/OTP
  static void logLogin(String method) {
    _fb.logEvent(name: 'fb_mobile_complete_registration', parameters: {
      'registration_method': method,
    });
  }

  // 2. Log when user clicks a Service Category
  static void logViewService(String categoryName) {
    _fb.logViewContent(
      id: categoryName,
      type: 'service_category',
      currency: 'INR',
      price: 0,
    );
  }

  // 3. Log Add to Cart
  static void logAddToCart(String serviceName, double price) {
    _fb.logAddToCart(
      id: serviceName,
      type: 'service',
      currency: 'INR',
      price: price,
    );
  }

  // 4. Log Successful Payment (Critical for ROAS)
  static void logPurchase(double amount, String orderId) {
    _fb.logPurchase(
      amount: amount,
      currency: 'INR',
      parameters: {
        'order_id': orderId,
        'content_type': 'service_booking',
      },
    );
  }
}