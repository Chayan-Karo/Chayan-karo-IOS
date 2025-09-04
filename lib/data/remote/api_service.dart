import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../../models/home_models.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://your-api-base-url.com/api/")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/home/data")
  Future<HomeData> getHomeData();

  @GET("/categories")
  Future<List<ServiceCategory>> getCategories();

  @GET("/services/goto")
  Future<List<GoToService>> getGoToServices();

  @GET("/services/most-used")
  Future<List<Service>> getMostUsedServices();
}
