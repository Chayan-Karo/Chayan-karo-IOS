import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../entities/category_entity.dart';
import '../entities/service_entity.dart';

part 'home_api_client.g.dart';

// Remove @JsonSerializable - this class doesn't need it
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  // Manual fromJson for generic handling
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

@RestApi()
abstract class HomeApiClient {
  factory HomeApiClient(Dio dio, {String baseUrl}) = _HomeApiClient;

  // TODO: Replace with your actual API endpoints
  @GET('/api/categories')
  Future<ApiResponse<List<CategoryEntity>>> getCategories();

  @GET('/api/services')
  Future<ApiResponse<List<ServiceEntity>>> getAllServices();

  @GET('/api/services/category/{categoryId}')
  Future<ApiResponse<List<ServiceEntity>>> getServicesByCategory(
    @Path('categoryId') String categoryId,
  );

  @GET('/api/services/popular')
  Future<ApiResponse<List<ServiceEntity>>> getPopularServices();

  @GET('/api/services/most-used')
  Future<ApiResponse<List<ServiceEntity>>> getMostUsedServices();
}
