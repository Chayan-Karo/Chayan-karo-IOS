import 'package:get/get.dart';
import '../data/local/database.dart';

class CacheService extends GetxService {
  final AppDatabase _database = Get.find<AppDatabase>();

  // Location related methods
  Future<String?> getLocationLabel() async {
    try {
      return await _database.getLocationLabel();
    } catch (e) {
      print('Error getting location label: $e');
      return null;
    }
  }

  Future<String?> getLocationAddress() async {
    try {
      return await _database.getLocationAddress();
    } catch (e) {
      print('Error getting location address: $e');
      return null;
    }
  }

  Future<void> saveLocation(String label, String address) async {
    try {
      await _database.saveLocation(label, address);
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  // User preferences
  Future<void> saveUserPreference(String key, String value) async {
    try {
      await _database.saveUserPreference(key, value);
    } catch (e) {
      print('Error saving user preference: $e');
    }
  }

  Future<String?> getUserPreference(String key) async {
    try {
      return await _database.getUserPreference(key);
    } catch (e) {
      print('Error getting user preference: $e');
      return null;
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _database.clearAllCache();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
