// lib/data/remote/api_service.dart
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../models/auth_models.dart';
import '../../models/home_models.dart';
import '../../models/customer_models.dart';
import '../../models/category_models.dart';
import '../../models/service_models.dart';
import '../../models/location_models.dart';
import '../../models/saathi_models.dart';
import '../../models/payment_models.dart';
import '../../models/booking_models.dart';
import '../../models/reschedule_models.dart';
import '../../models/cancel_models.dart';
import 'dart:io'; // Add this for File
//import '../../models/booking_read_models.dart';
import '../../models/feedback_req_model.dart'; // Add this import

part 'api_service.g.dart';

@RestApi(baseUrl: "https://api.chayankaro.com")
abstract class ApiService {
  factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

  // Auth
  @POST('/user/login')
  Future<OtpResponse> sendOtp(@Body() SendOtpRequest request);

  @POST('/user/verifyOTP')
  Future<AuthResponse> verifyOtp(@Body() VerifyOtpRequest request);

  @POST('/user/refreshToken')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  // Customer
  @GET('/user/getCustomer')
  Future<CustomerResponse> getCustomer(@Header("Authorization") String authorization);

  @POST('/user/updateCustomerProfile')
  Future<void> updateCustomerProfile(
    @Header("Authorization") String authorization,
    @Body() Map<String, dynamic> updateBody,
  );
  @POST('/user/uploadUserProfile')
  @MultiPart()
  Future<void> uploadProfilePicture(
    @Header("Authorization") String authorization,
    @Part(name: "file") File file, // Matches 'file' key in backend
  );

  // Category
  @GET('/user/getCategory')
  Future<CategoryResponse> getCategories(@Header("Authorization") String authorization);

  // Services
  @GET('/user/getServices')
  Future<ServiceResponse> getServices(
    @Header("Authorization") String authorization,
    @Query("serviceCategoryId") String serviceCategoryId,
  );

  // Location
  @POST('/user/addCustomerAddress')
  Future<AddAddressResponse> addCustomerAddress(
    @Header("Authorization") String authorization,
    @Body() AddAddressRequest request,
  );

  @GET('/user/getCustomerAddress')
  Future<GetCustomerAddressesResponse> getCustomerAddresses(
    @Header("Authorization") String token,
  );
// Add this to your ApiService interface
  @DELETE("/user/deleteCustomerAddress")
  Future<BaseResponse> deleteCustomerAddress(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );
  // Saathi
 @POST('/user/getServiceProvider')
  Future<SaathiResponse> getServiceProvider(
    @Header("Authorization") String token,
    @Body() GetProvidersRequest body,
  );
// In your ApiService file (e.g., api_service.dart)

@GET('/user/lockServiceProvider')
Future<LockProviderResponse> lockServiceProvider(
  @Header("Authorization") String authorization,
  @Query("serviceProviderId") String serviceProviderId,
  @Query("date") String date, // <--- ADDED THIS
);


  // Booking (model-based)
  @POST('/user/addBooking')
  Future<AddBookingResponse> addBooking(
    @Header('Authorization') String authorization,
    @Body() AddBookingRequest body,
  );

  // Booking (raw-map fallback) — add this
  @POST('/user/addBooking')
  Future<AddBookingResponse> addBookingRaw(
    @Header('Authorization') String authorization,
    @Body() Map<String, dynamic> body,
  );

  // Payment
  @POST('/user/createOrder')
  Future<CreateOrderResponse> createOrder(
    @Header("Authorization") String authorization,
    @Body() CreateOrderRequest request,
  );
    @POST('/user/updatePayment')
  Future<dynamic> updatePayment(
    @Header("Authorization") String authorization,
    @Body() Map<String, dynamic> body, // { bookingId, orderId, paymentId, signature }
  );
@GET('/user/getCustomerBooking')
Future<HttpResponse<Object?>> getCustomerBookingsRaw(
  @Header("Authorization") String authorization,
);

// Location coverage
@GET('/user/getLocation')
Future<ServiceLocationsResponse> getServiceableLocations(
  @Header("Authorization") String authorization,
);
@POST('/user/rescheduleBooking')
Future<RescheduleBookingEnvelope> rescheduleBooking(
  @Header('Authorization') String bearer,
  @Body() RescheduleBookingRequest body,
);

@POST('/user/rescheduleBooking')
Future<RescheduleBookingEnvelope> rescheduleBookingRaw(
  @Header('Authorization') String bearer,
  @Body() Map<String, dynamic> body,
);

 @POST('/user/cancelBooking')
Future<CancelBookingEnvelope> cancelBookingRaw(
  @Header('Authorization') String bearer,
  @Body() Map<String, dynamic> body,
);
@POST('/user/serviceProviderRating')
  Future<void> rateServiceProvider(
    @Header("Authorization") String token,
    @Body() ServiceProviderRatingRequest body,
  );

  @POST('/user/serviceBookingRating')
  Future<void> rateServiceBooking(
    @Header("Authorization") String token,
    @Body() ServiceBookingRatingRequest body,
  );

}
