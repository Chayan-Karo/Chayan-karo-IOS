// lib/data/remote/api_service.dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../models/auth_models.dart';
import '../../models/home_models.dart';
import '../../models/customer_models.dart';
import '../../models/category_models.dart';
import '../../models/service_models.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "http://65.1.234.42:8081")
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  // Auth endpoints
  @POST('/user/login')
  Future<OtpResponse> sendOtp(@Body() SendOtpRequest request);

  @POST('/user/verifyOTP')
  Future<AuthResponse> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/user/refreshToken')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  // Customer Profile endpoints
  @GET('/user/getCustomer')
  Future<CustomerResponse> getCustomer(@Header("Authorization") String authorization);

  @POST('/user/updateCustomerProfile')
  Future<void> updateCustomerProfile(
    @Header("Authorization") String authorization,
    @Body() Map<String, dynamic> updateBody
  );

  // Category endpoints
  @GET('/user/getCategory')
  Future<CategoryResponse> getCategories(@Header("Authorization") String authorization);

  // Service endpoints - CORRECTED
  @GET('/user/getServices')
  Future<ServiceResponse> getServices(
    @Header("Authorization") String authorization,
    @Query("serviceCategoryId") String serviceCategoryId,
  );
}
