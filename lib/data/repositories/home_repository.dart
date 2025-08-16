import '../entities/category_entity.dart';
import '../entities/service_entity.dart';

abstract class HomeRepository {
  Future<List<CategoryEntity>> getCategories({bool forceRefresh = false});
  Future<List<ServiceEntity>> getAllServices({bool forceRefresh = false});
  Future<List<ServiceEntity>> getServicesByCategory(String category, {bool forceRefresh = false});
  Future<List<ServiceEntity>> getMostUsedServices({bool forceRefresh = false});
  Future<List<ServiceEntity>> getPopularServices({bool forceRefresh = false});
  
  // Location methods
  Future<String> getSavedLocationLabel();
  Future<String> getSavedLocationAddress();
  Future<void> updateLocation(String label, String address);
}
