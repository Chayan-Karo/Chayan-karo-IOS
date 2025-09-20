import 'package:get/get.dart';
import 'package:dio/dio.dart';

// Controllers
import '../controllers/male_salon_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/salon_service_controller.dart';
import '../controllers/female_spa_controller.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/male_spa_controller.dart';

// Services and Data
import '../services/cache_service.dart';
import '../data/repository/home_repository.dart';
import '../data/repository/auth_repository.dart'; // Add this
import '../data/local/database.dart';
import '../data/remote/network_client.dart';        // Add this
import '../data/remote/api_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 Registering GetX dependencies...');
    
    // STEP 1: Core Infrastructure (permanent dependencies)
    _registerCoreServices();
    
    // STEP 2: Network Layer (singleton pattern)
    _registerNetworkLayer();
    
    // STEP 3: Repositories (lazy loading for memory efficiency)
    _registerRepositories();
    
    // STEP 4: Controllers (based on usage patterns)
    _registerControllers();
    
    print('🎉 All GetX dependencies registered successfully');
  }
  
  void _registerCoreServices() {
    print('📦 Registering core services...');
    
    // Database - Permanent (needed throughout app lifecycle)
    Get.put<AppDatabase>(AppDatabase(), permanent: true);
    print('✅ AppDatabase registered (permanent)');
    
    // Cache Service - Permanent
    Get.put<CacheService>(CacheService(), permanent: true);
    print('✅ CacheService registered (permanent)');
  }
  
  void _registerNetworkLayer() {
    print('🌐 Registering network layer...');
    
    // Singleton NetworkClient - will handle Dio configuration internally
    final networkClient = NetworkClient();
    Get.put<NetworkClient>(networkClient, permanent: true);
    
    // API Service from NetworkClient singleton
    Get.put<ApiService>(networkClient.apiService, permanent: true);
    print('✅ NetworkClient & ApiService registered (singleton pattern)');
  }
  
  void _registerRepositories() {
    print('📚 Registering repositories...');
    
    // Home Repository - Lazy loading with dependency injection
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(
        apiService: Get.find<ApiService>(),
        database: Get.find<AppDatabase>(),
      ),
      fenix: true,
    );
    print('✅ HomeRepository registered (lazy)');
    
    // Auth Repository - Lazy loading for login/auth screens
    Get.lazyPut<AuthRepository>(
      () => AuthRepository(),
      fenix: true,
    );
    print('✅ AuthRepository registered (lazy)');
  }
  
  void _registerControllers() {
    print('🎮 Registering controllers...');
    
    // Service Controllers - Permanent (used across multiple screens)
    Get.put<SalonServicesController>(SalonServicesController(), permanent: true);
    Get.put<FemaleSpaController>(FemaleSpaController(), permanent: true); 
    Get.put<MaleSpaController>(MaleSpaController(), permanent: true); 
    Get.put<MaleSalonController>(MaleSalonController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    print('✅ Service & Cart controllers registered (permanent)');
    
    // Navigation Controllers - Lazy (only created when screens are accessed)
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
    Get.lazyPut<OtpController>(() => OtpController(), fenix: true);
    print('✅ Auth controllers registered (lazy)');
    
    // Home Controller - Lazy (main screen but not always needed immediately)
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    print('✅ HomeController registered (lazy)');
  }
}
