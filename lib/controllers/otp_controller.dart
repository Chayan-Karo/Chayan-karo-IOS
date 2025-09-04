import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../data/local/database.dart';
import 'home_controller.dart';

class OtpController extends GetxController {
  AppDatabase get _database => Get.find<AppDatabase>();

  // Reactive variables
  final _secondsRemaining = 60.obs;
  final _canResend = false.obs;
  final _phoneNumber = ''.obs;
  final _isLoading = false.obs;
  final _isButtonEnabled = false.obs;

  // Timer for countdown
  Timer? _timer;
  
  // OTP controllers
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  // Getters
  int get secondsRemaining => _secondsRemaining.value;
  bool get canResend => _canResend.value;
  String get phoneNumber => _phoneNumber.value;
  bool get isLoading => _isLoading.value;
  bool get isButtonEnabled => _isButtonEnabled.value;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize controllers and focus nodes
    otpControllers = List.generate(4, (_) => TextEditingController());
    focusNodes = List.generate(4, (_) => FocusNode());
    
    // Get phone number from arguments
    if (Get.arguments != null && Get.arguments['phone'] != null) {
      _phoneNumber.value = Get.arguments['phone'];
    }

    // Add listeners to check if all fields are filled
    for (int i = 0; i < otpControllers.length; i++) {
      otpControllers[i].addListener(_checkOtpComplete);
    }

    // Start the timer
    _startTimer();
    
    print('📱 OtpController initialized for phone: ${_phoneNumber.value}');
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }

  void _checkOtpComplete() {
    final otp = otpControllers.map((e) => e.text).join();
    _isButtonEnabled.value = otp.length == 4;
  }

  void _startTimer() {
    _canResend.value = false;
    _secondsRemaining.value = 60;
    
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_secondsRemaining.value == 0) {
        _canResend.value = true;
        timer.cancel();
      } else {
        _secondsRemaining.value--;
      }
    });
  }

  String get currentOtp => otpControllers.map((e) => e.text).join();

  Future<void> verifyOTP() async {
    final otp = currentOtp;
    
    if (otp.length != 4) {
      print('❌ Invalid OTP: Please enter the complete 4-digit OTP');
      return;
    }

    _isLoading.value = true;
    
    try {
      // Simulate API call for OTP verification
      final isValid = await _verifyOTPWithAPI(otp, _phoneNumber.value);
      
      if (isValid) {
        await _handleSuccessfulVerification();
      } else {
        print('❌ Verification Failed: Invalid OTP. Please check and try again.');
        _clearOtpFields();
      }
    } catch (e) {
      print('❌ OTP verification error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> _verifyOTPWithAPI(String otp, String phone) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, accept any 4-digit OTP
    // Replace this with your actual API call
    print('🔐 Verifying OTP: $otp for phone: +91$phone');
    return otp.length == 4;
    
    // Real implementation would be:
    // final response = await apiService.verifyOTP(phone: phone, otp: otp);
    // return response.success;
  }

  Future<void> _handleSuccessfulVerification() async {
    try {
      // Generate user data (in real app, this would come from API response)
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save login state to database
      await _database.saveLoginState(
        isLoggedIn: true,
        userId: userId,
        userToken: userToken,
        userPhone: _phoneNumber.value,
        userName: 'User', // You can get this from a form or API
      );

      print('✅ Login successful for +91${_phoneNumber.value}');

      // Navigate to home silently
      Get.offAllNamed('/home');
      
      // Refresh home controller data if registered
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initialize();
      }
      
    } catch (e) {
      print('❌ Error saving login state: $e');
    }
  }

  Future<void> resendOTP() async {
    if (_phoneNumber.value.isEmpty) {
      print('❌ Error: Phone number not found');
      return;
    }

    try {
      // Simulate API call for resending OTP
      await Future.delayed(Duration(seconds: 1));
      
      print('📱 OTP resent to +91 ${_phoneNumber.value}');
      
      // Clear current OTP and restart timer
      _clearOtpFields();
      _startTimer();
      
    } catch (e) {
      print('❌ Error resending OTP: $e');
    }
  }

  void _clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    // Focus on first field
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
  }

  void onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }
}
