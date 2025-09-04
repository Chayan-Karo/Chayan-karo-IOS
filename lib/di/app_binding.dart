import '../controllers/male_salon_controller.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../services/cache_service.dart';
import '../data/repository/home_repository.dart';
import '../data/local/database.dart';
import '../data/remote/api_service.dart';
import '../controllers/salon_service_controller.dart';
import '../controllers/female_spa_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/male_spa_controller.dart';
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Create Dio instance with proper configuration
    final dio = Dio();
    
    // Configure Dio for better error handling
    dio.options.connectTimeout = Duration(milliseconds: 30000);
    dio.options.receiveTimeout = Duration(milliseconds: 30000);
    dio.options.sendTimeout = Duration(milliseconds: 30000);
    
    // Add interceptor for debugging (optional)
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
    
    // Core services - These should be permanent
    Get.put<AppDatabase>(AppDatabase(), permanent: true);
    
    // Use a placeholder URL that won't cause network errors
    Get.put<ApiService>(
      ApiService(dio, baseUrl: 'https://jsonplaceholder.typicode.com'),
      permanent: true,
    );
    Get.put<CacheService>(CacheService(), permanent: true);
    
    // Repository
    Get.put<HomeRepository>(
      HomeRepository(
        apiService: Get.find<ApiService>(),
        database: Get.find<AppDatabase>(),
      ),
      permanent: true,
    );
    
    // FIXED: Use Get.put instead of Get.lazyPut to ensure immediate initialization
    Get.put<SalonServicesController>(SalonServicesController(), permanent: true);
    Get.put<FemaleSpaController>(FemaleSpaController(), permanent: true); 
    Get.put<MaleSpaController>(MaleSpaController(), permanent: true); 
    Get.put<MaleSalonController>(MaleSalonController(), permanent: true);

    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<OtpController>(() => OtpController());
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: false); // Changed from lazyPut
  }
}
