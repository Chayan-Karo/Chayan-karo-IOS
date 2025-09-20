import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/local/database.dart';
import '../data/repository/auth_repository.dart'; // Fixed import path

class LoginController extends GetxController {
  AppDatabase get _database => Get.find<AppDatabase>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final _phoneNumber = ''.obs;
  final _isButtonEnabled = false.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  
  late TextEditingController phoneController;

  // Getters
  String get phoneNumber => _phoneNumber.value;
  bool get isButtonEnabled => _isButtonEnabled.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    
    phoneController.addListener(() {
      _phoneNumber.value = phoneController.text;
      _isButtonEnabled.value = phoneController.text.length == 10;
      if (_errorMessage.value.isNotEmpty) {
        _errorMessage.value = '';
      }
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
      _errorMessage.value = 'Please enter a valid 10-digit phone number';
      return;
    }

    _isLoading.value = true;
    _errorMessage.value = '';
    
    try {
      final response = await _authRepository.sendOtp(_phoneNumber.value);
      
      if (response.success) {
        print('✅ OTP sent successfully to: +91${_phoneNumber.value}');
        print('📥 Response: type=${response.type}, message=${response.message}');
        
        // Navigate to OTP screen with just phone number (no otpId from this API)
        Get.toNamed('/otp', arguments: {
          'phone': _phoneNumber.value,
          'message': response.message, // Pass the success message if needed
        });
      } else {
        _errorMessage.value = response.message;
        print('❌ OTP sending failed: ${response.message}');
      }
      
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _errorMessage.value = 'An unexpected error occurred. Please try again.';
      print('❌ Unexpected error sending OTP: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        _errorMessage.value = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        _errorMessage.value = 'No internet connection. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error occurred';
        
        if (statusCode == 429) {
          _errorMessage.value = 'Too many attempts. Please try again later.';
        } else if (statusCode == 400) {
          _errorMessage.value = message;
        } else {
          _errorMessage.value = 'Server error. Please try again later.';
        }
        break;
      default:
        _errorMessage.value = 'Something went wrong. Please try again.';
    }
  }

  Future<void> checkOnboardingStatus() async {
    try {
      final hasSeenOnboarding = await _database.hasSeenOnboarding();
      print('👀 Has seen onboarding: $hasSeenOnboarding');
    } catch (e) {
      print('❌ Error checking onboarding status: $e');
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
