import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/local/database.dart';

class LoginController extends GetxController {
  AppDatabase get _database => Get.find<AppDatabase>();

  final _phoneNumber = ''.obs;
  final _isButtonEnabled = false.obs;
  final _isLoading = false.obs;
  
  // Text controller for the input field
  late TextEditingController phoneController;

  // Getters
  String get phoneNumber => _phoneNumber.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    
    // Listen to text changes
    phoneController.addListener(() {
      _phoneNumber.value = phoneController.text;
      _isButtonEnabled.value = phoneController.text.length == 10;
    });
    
    print('📱 LoginController initialized');
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> sendOTP() async {
    if (_phoneNumber.value.length != 10) {
      print('❌ Invalid Phone Number: Please enter a valid 10-digit phone number');
      return;
    }

    _isLoading.value = true;
    
    try {
      // Simulate API call for sending OTP
      await Future.delayed(Duration(seconds: 2));
      
      print('✅ OTP sent to: +91${_phoneNumber.value}');
      
      // Navigate to OTP screen with phone number silently
      Get.toNamed('/otp', arguments: {'phone': _phoneNumber.value});
      
    } catch (e) {
      print('❌ Error sending OTP: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Method to check if user should skip onboarding
  Future<void> checkOnboardingStatus() async {
    try {
      final hasSeenOnboarding = await _database.hasSeenOnboarding();
      print('👀 Has seen onboarding: $hasSeenOnboarding');
    } catch (e) {
      print('❌ Error checking onboarding status: $e');
    }
  }
}
