import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/home_repository.dart';
import '../entities/category_entity.dart';
import '../entities/service_entity.dart';
import '../database/app_database.dart';
import '../api/home_api_client.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final AppDatabase _database;
  final HomeApiClient _apiClient;
  final SharedPreferences _prefs;

  HomeRepositoryImpl(this._database, this._apiClient, this._prefs);

  @override
  Future<List<CategoryEntity>> getCategories({bool forceRefresh = false}) async {
    try {
      // Try to get from cache first
      if (!forceRefresh) {
        final cachedCategories = await _database.categoryDao.getAllCategories();
        if (cachedCategories.isNotEmpty) {
          return cachedCategories;
        }
      }

      // Fetch from API
      final response = await _apiClient.getCategories();
      if (response.success && response.data != null) {
        // Clear old data and insert new
        await _database.categoryDao.clearAll();
        await _database.categoryDao.insertCategories(response.data!);
        return response.data!;
      }

      // Fallback to cache if API fails
      return await _database.categoryDao.getAllCategories();
    } catch (e) {
      // Return cached data or default data on error
      final cachedData = await _database.categoryDao.getAllCategories();
      if (cachedData.isNotEmpty) return cachedData;
      
      // Return default categories as fallback
      return _getDefaultCategories();
    }
  }

  @override
  Future<List<ServiceEntity>> getMostUsedServices({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedServices = await _database.serviceDao.getServicesByCategory('most_used');
        if (cachedServices.isNotEmpty) {
          return cachedServices;
        }
      }

      final response = await _apiClient.getMostUsedServices();
      if (response.success && response.data != null) {
        // Mark services as most_used category for easy filtering
        final mostUsedServices = response.data!.map((service) => 
          ServiceEntity(
            id: service.id,
            title: service.title,
            subtitle: service.subtitle,
            imagePath: service.imagePath,
            price: service.price,
            category: 'most_used',
            rating: service.rating,
            createdAt: service.createdAt,
          )
        ).toList();
        
        await _database.serviceDao.insertServices(mostUsedServices);
        return mostUsedServices;
      }

      return await _database.serviceDao.getServicesByCategory('most_used');
    } catch (e) {
      final cachedData = await _database.serviceDao.getServicesByCategory('most_used');
      if (cachedData.isNotEmpty) return cachedData;
      
      return _getDefaultMostUsedServices();
    }
  }

  @override
  Future<List<ServiceEntity>> getAllServices({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedServices = await _database.serviceDao.getAllServices();
        if (cachedServices.isNotEmpty) {
          return cachedServices;
        }
      }

      final response = await _apiClient.getAllServices();
      if (response.success && response.data != null) {
        await _database.serviceDao.clearAll();
        await _database.serviceDao.insertServices(response.data!);
        return response.data!;
      }

      return await _database.serviceDao.getAllServices();
    } catch (e) {
      return await _database.serviceDao.getAllServices();
    }
  }

  @override
  Future<List<ServiceEntity>> getServicesByCategory(String category, {bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedServices = await _database.serviceDao.getServicesByCategory(category);
        if (cachedServices.isNotEmpty) {
          return cachedServices;
        }
      }

      final response = await _apiClient.getServicesByCategory(category);
      if (response.success && response.data != null) {
        await _database.serviceDao.insertServices(response.data!);
        return response.data!;
      }

      return await _database.serviceDao.getServicesByCategory(category);
    } catch (e) {
      return await _database.serviceDao.getServicesByCategory(category);
    }
  }

  @override
  Future<List<ServiceEntity>> getPopularServices({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedServices = await _database.serviceDao.getServicesByCategory('popular');
        if (cachedServices.isNotEmpty) {
          return cachedServices;
        }
      }

      final response = await _apiClient.getPopularServices();
      if (response.success && response.data != null) {
        final popularServices = response.data!.map((service) => 
          ServiceEntity(
            id: service.id,
            title: service.title,
            subtitle: service.subtitle,
            imagePath: service.imagePath,
            price: service.price,
            category: 'popular',
            rating: service.rating,
            createdAt: service.createdAt,
          )
        ).toList();
        
        await _database.serviceDao.insertServices(popularServices);
        return popularServices;
      }

      return await _database.serviceDao.getServicesByCategory('popular');
    } catch (e) {
      return await _database.serviceDao.getServicesByCategory('popular');
    }
  }

  @override
  Future<String> getSavedLocationLabel() async {
    return _prefs.getString('location_label') ?? 'Home';
  }

  @override
  Future<String> getSavedLocationAddress() async {
    return _prefs.getString('location_address') ?? 'Not Available';
  }

  @override
  Future<void> updateLocation(String label, String address) async {
    await _prefs.setString('location_label', label);
    await _prefs.setString('location_address', address);
  }

  // Default fallback data
  List<CategoryEntity> _getDefaultCategories() {
    final now = DateTime.now();
    return [
      CategoryEntity(title: 'Female Saloon', iconPath: 'assets/icons/female_saloon.svg', createdAt: now),
      CategoryEntity(title: 'Female Spa', iconPath: 'assets/icons/female_spa.svg', createdAt: now),
      CategoryEntity(title: 'Male Saloon', iconPath: 'assets/icons/male_saloon.svg', createdAt: now),
      CategoryEntity(title: 'Male Spa', iconPath: 'assets/icons/male_spa.svg', createdAt: now),
      CategoryEntity(title: 'Hair & Skin', iconPath: 'assets/icons/hair_skin.svg', createdAt: now),
      CategoryEntity(title: 'Home Repairs', iconPath: 'assets/icons/home_repairs.svg', createdAt: now),
      CategoryEntity(title: 'Cleaning', iconPath: 'assets/icons/cleaning.svg', createdAt: now),
      CategoryEntity(title: 'AC Services', iconPath: 'assets/icons/ac_service.svg', createdAt: now),
    ];
  }

  List<ServiceEntity> _getDefaultMostUsedServices() {
    final now = DateTime.now();
    return [
      ServiceEntity(title: 'Window AC frame Installation', imagePath: 'assets/z1.webp', category: 'most_used', createdAt: now),
      ServiceEntity(title: 'Women Salon Services', imagePath: 'assets/z2.webp', category: 'most_used', createdAt: now),
      ServiceEntity(title: 'Home Deep Cleaning', imagePath: 'assets/z3.webp', category: 'most_used', createdAt: now),
      ServiceEntity(title: 'Spa for Men', imagePath: 'assets/z4.webp', category: 'most_used', createdAt: now),
    ];
  }
}
