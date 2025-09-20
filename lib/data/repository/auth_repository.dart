import '../remote/network_client.dart';
import '../../models/auth_models.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final NetworkClient _networkClient = NetworkClient();

  // Existing method using models
  Future<OtpResponse> sendOtp(String phoneNumber) async {
    try {
      final request = SendOtpRequest(mobileNo: phoneNumber);
      print('📤 Sending OTP request: ${request.toJson()}');
      
      return await _networkClient.apiService.sendOtp(request);
    } catch (e) {
      print('❌ Auth Repository - Send OTP Error: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD - Generic send OTP
  Future<Map<String, dynamic>> sendOtpGeneric(String phoneNumber) async {
    try {
      final dio = Dio();
      dio.options.headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final data = {'mobileNo': phoneNumber};
      print('📤 Sending OTP request (generic): $data');

      final response = await dio.post(
        'http://65.1.234.42:8081/Authentication/Login',
        data: data,
      );

      print('📥 Raw send OTP response: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData;
      } else {
        throw Exception('Failed to send OTP: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Auth Repository - Send OTP Error (generic): $e');
      rethrow;
    }
  }

  // Existing method using models
  Future<AuthResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final request = VerifyOtpRequest(
        mobileNo: phoneNumber,
        otp: otp,
      );
      
      print('📤 Verifying OTP request: ${request.toJson()}');
      
      return await _networkClient.apiService.verifyOtp(request);
    } catch (e) {
      print('❌ Auth Repository - Verify OTP Error: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD - Generic verify OTP
  Future<Map<String, dynamic>> verifyOtpGeneric({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final dio = Dio();
      dio.options.headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final data = {
        'mobileNo': phoneNumber,
        'otp': otp,
      };
      
      print('📤 Verifying OTP request (generic): $data');

      final response = await dio.post(
        'http://65.1.234.42:8081/Authentication/VerifyOTP',
        data: data,
      );

      print('📥 Raw verify response: ${response.data}');
      
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        return responseData;
      } else {
        throw Exception('Failed to verify OTP: ${response.statusCode}');
      }
      
    } catch (e) {
      print('❌ Auth Repository - Verify OTP Error (generic): $e');
      rethrow;
    }
  }

  // Existing refresh token method
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      return await _networkClient.apiService.refreshToken(request);
    } catch (e) {
      print('❌ Auth Repository - Refresh Token Error: $e');
      rethrow;
    }
  }

  // Test method for debugging
  Future<void> testApiRequest(String phoneNumber) async {
    try {
      print('🧪 Testing API request format...');
      
      final dio = Dio();
      dio.options.headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final data = {
        'mobileNo': phoneNumber,
      };

      print('📤 Test request data: $data');

      final response = await dio.post(
        'http://65.1.234.42:8081/Authentication/Login',
        data: data,
      );

      print('✅ Test request successful: ${response.statusCode}');
      print('📥 Response: ${response.data}');
      
    } catch (e) {
      print('❌ Test request failed: $e');
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request Data: ${e.requestOptions.data}');
      }
    }
  }

  // Test verify OTP method for debugging
  Future<void> testVerifyOtpRequest(String phoneNumber, String otp) async {
    try {
      print('🧪 Testing OTP verification request...');
      
      final dio = Dio();
      dio.options.headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final data = {
        'mobileNo': phoneNumber,
        'otp': otp,
      };

      print('📤 Test verify request data: $data');

      final response = await dio.post(
        'http://65.1.234.42:8081/Authentication/VerifyOTP',
        data: data,
      );

      print('✅ Test verify request successful: ${response.statusCode}');
      print('📥 Response: ${response.data}');
      
    } catch (e) {
      print('❌ Test verify request failed: $e');
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request Data: ${e.requestOptions.data}');
      }
    }
  }
}
