import 'dart:convert';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/repository/payment_repository.dart';
import '../controllers/profile_controller.dart';
import '../widgets/app_snackbar.dart';

class PaymentController extends GetxController {
  PaymentRepository get _repository => PaymentRepository();

  late Razorpay _razorpay;

  final isLoading = false.obs;
  final selectedMethod = Rxn<String>();
  final errorMessage = ''.obs;
  final paymentCancelled = false.obs;

  double? bookingAmount;
  Map<String, dynamic>? bookingMetadata;
  String? bookingId;
  Map<String, dynamic>? bookingCardData;
  String? currentOrderId;
  String? currentReceipt;

  // REQUIRED: put your Test/Live key id here (never secret on client)
  //static const String _razorpayKeyId = 'rzp_test_RRgyDlYscS5byz'; 
  static const String _razorpayKeyId = 'rzp_live_RhxSMhLgNrnI7m'; 


  // Prefill fields
  String _prefillContact = '';
  String _prefillEmail = '';

  // Normalize to E.164
  String _toE164(String raw) {
    final t = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (t.isEmpty) return '';
    if (t.startsWith('+')) return t;
    if (RegExp(r'^[0-9]{10}$').hasMatch(t)) return '+91$t';
    return t;
  }

  void _debugLog(String label, Object? data) {
    try {
      print('[$label] ${jsonEncode(data)}');
    } catch (_) {
      print('[$label] $data');
    }
  }

  // Called from PaymentScreen optionally
  void setPrefill({required String contact, required String email}) {
    _prefillContact = _toE164(contact);
    _prefillEmail = email.trim();
    _debugLog('setPrefill.contact', _prefillContact);
    _debugLog('setPrefill.email', _prefillEmail);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void setBookingDetails({
    required double amount,
    Map<String, dynamic>? metadata,
    String? bookingId,
    Map<String, dynamic>? bookingCard, // <--- Added this parameter
  }) {
    bookingAmount = amount;
    bookingMetadata = metadata;
    this.bookingId = bookingId;
    bookingCardData = bookingCard; // Store it
    _debugLog('setBookingDetails.amount', bookingAmount);
    _debugLog('setBookingDetails.bookingId', bookingId);
    _debugLog('setBookingDetails.metadata', bookingMetadata);
    
  }

  void selectPaymentMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> initiatePaymentDirect() async {
    if (bookingAmount == null) {
      AppSnackbar.showError('Booking amount missing');
      Get.back();
      return;
    }
    if ((bookingId ?? '').isEmpty) {
      AppSnackbar.showError('Booking ID missing');
      return;
    }
    paymentCancelled.value = false;
    selectedMethod.value = 'Card';
    await _processOnlinePayment();
  }

  Future<void> initiatePayment() async {
    if (selectedMethod.value == null) {
      AppSnackbar.showWarning('Please select a payment method');
      return;
    }
    if (bookingAmount == null) {
      AppSnackbar.showError('Booking amount missing');
      return;
    }
    if (selectedMethod.value == 'Cash') {
      _processCashPayment();
      return;
    }
    if ((bookingId ?? '').isEmpty) {
      AppSnackbar.showError('Booking ID missing');
      return;
    }
    await _processOnlinePayment();
  }

  Future<void> _processOnlinePayment() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('💳 Initiating Razorpay: amount=₹$bookingAmount bookingId=$bookingId');

      // Create order on server (secret stays server-side)
      final orderDetails = await _repository.createOrder(
        amount: bookingAmount!,
        bookingId: bookingId!,
      );

      currentOrderId = orderDetails.id;
      currentReceipt = orderDetails.receipt;

      if (currentOrderId == null) {
        throw Exception('Order ID missing');
      }

      // Build authoritative contact/email with multi-source fallback
      final profile = Get.find<ProfileController>();

      String chooseFirstNonEmpty(List<String> v) =>
          v.firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');

      final chosenPhoneRaw = chooseFirstNonEmpty([
        _prefillContact,
        profile.userPhone,                              // getter from controller
        profile.customer?.mobileNo ?? '',               // model fallback
        (bookingMetadata?['phone'] ?? '').toString(),   // route metadata
      ]);

      final chosenEmail = chooseFirstNonEmpty([
        _prefillEmail,
        profile.customer?.emailId ?? '',
        (bookingMetadata?['email'] ?? '').toString(),
      ]);

      final mergedContact = _toE164(chosenPhoneRaw);
      final mergedEmail = chosenEmail.trim();

      _debugLog('prefill.final.contact', mergedContact);
      _debugLog('prefill.final.email', mergedEmail);

      // Validate critical fields before opening Checkout
      final hasValidKey = _razorpayKeyId.trim().isNotEmpty;
      final isLikelyE164 = RegExp(r'^\+\d{8,15}$').hasMatch(mergedContact);

      if (!hasValidKey) {
        isLoading.value = false;
        AppSnackbar.showError('Razorpay Key ID is missing.');
        return;
      }
      if (!isLikelyE164) {
        isLoading.value = false;
        AppSnackbar.showWarning('Add a valid mobile number to continue.');
        return;
      }

      isLoading.value = false;

      final options = {
        'key': _razorpayKeyId,                            // REQUIRED by SDK [web:4]
        'amount': orderDetails.amount ?? (bookingAmount! * 100).toInt(),
        'currency': 'INR',
        'name': 'Chayan Karo',
        'description': 'Service Booking Payment',
        'order_id': currentOrderId,                       // REQUIRED for Orders flow [web:2]
        'prefill': {
          'contact': mergedContact,                      // +{cc}{number} required format [web:3][web:33]
          'email': mergedEmail,                          // optional but recommended [web:3]
        },
        // Keep readonly for verification runs; you can disable later
        'readonly': {'contact': true, 'email': mergedEmail.isNotEmpty},
        'theme': {'color': '#E47830'},
      };

      _debugLog('razorpay.options', options);

      print('🚀 Opening Razorpay checkout…');
      _razorpay.open(options);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      print('❌ _processOnlinePayment error: $e');

      AppSnackbar.showError('Failed to create order: $e');
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.currentRoute == '/payment') Get.back();
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (paymentCancelled.value) return;
    _debugLog('RZP.success.paymentId', response.paymentId);
    _debugLog('RZP.success.orderId', response.orderId);
    _debugLog('RZP.success.signature', response.signature);

    try {
      isLoading.value = true;

    // 1. Capture the response in a variable (apiResponse)
      final apiResponse = await _repository.updatePayment(
        bookingId: bookingId!,
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
      );

      isLoading.value = false;
      
      Get.offNamed('/payment-success', arguments: {
        'orderId': response.orderId,
        'paymentId': response.paymentId,
        'signature': response.signature,
        'receipt': currentReceipt,
        'amount': bookingAmount,
        'method': selectedMethod.value ?? 'Online Payment',
        'bookingId': bookingId,
        'bookingCard': bookingCardData,
        
        // 2. Extract and pass the bookingReferenceNumber
        'bookingReferenceNumber': apiResponse['result']?['bookingReferenceNumber'], 
      });

    } catch (e) {
      isLoading.value = false;
      print('❌ updatePayment failed: $e');
      Get.offNamed('/payment-failed', arguments: {
        'message': 'Payment verification failed. ${e.toString()}',
        'orderId': response.orderId,
        'paymentId': response.paymentId,
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    paymentCancelled.value = true;

    _debugLog('RZP.error.code', response.code);
    _debugLog('RZP.error.message', response.message);
    _debugLog('RZP.error.payload', response.error);

    Get.offNamed('/payment-failed', arguments: {
      'message': response.message ?? 'Payment cancelled or failed.',
      'orderId': response.error?['metadata']?['order_id'],
      'paymentId': response.error?['metadata']?['payment_id'],
    });
  }

  void cancelPayment() {
    paymentCancelled.value = true;
    print('🚫 Payment cancelled by user');
    Get.offNamed('/payment-failed', arguments: {
      'message': 'Payment cancelled by user.',
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _debugLog('RZP.externalWallet', response.walletName);
    AppSnackbar.showInfo('Wallet: ${response.walletName}');
  }

  void _processCashPayment() {
    print('💵 Processing cash payment');
    Get.offNamed('/payment-success', arguments: {
      'amount': bookingAmount,
      'method': 'Cash',
      'receipt': 'CASH_${DateTime.now().millisecondsSinceEpoch}',
      'bookingId': bookingId,
    });
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
