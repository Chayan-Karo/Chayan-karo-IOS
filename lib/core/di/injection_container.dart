import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../domain/repositories/home_repository.dart';
import '../data/entities/category_entity.dart';
import '../data/entities/service_entity.dart';

@injectable
class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel(this._repository);

  // State variables
  String _address = 'Fetching location...';
  String _locationLabel = 'Home';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Data
  List<CategoryEntity> _categories = [];
  List<ServiceEntity> _mostUsedServices = [];
  List<Map<String, dynamic>> _goToServices = [];

  // Getters
  String get address => _address;
  String get locationLabel => _locationLabel;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  
  List<Map<String, String>> get categories => _categories.map((cat) => {
    'title': cat.title,
    'icon': cat.iconPath,
  }).toList();
  
  List<Map<String, String>> get mostUsedServices => _mostUsedServices.map((service) => {
    'image': service.imagePath,
    'title': service.title,
  }).toList();
  
  List<Map<String, dynamic>> get goToServices => _goToServices;

  // Initialize
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Future.wait([
        _loadLocationData(),
        _loadCategories(),
        _loadMostUsedServices(),
        _loadGoToServices(),
      ]);
    } catch (e) {
      _setError('Failed to initialize home data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    _setLoading(true);
    _clearError();
    
    try {
      await Future.wait([
        _loadCategories(forceRefresh: true),
        _loadMostUsedServices(forceRefresh: true),
        _loadGoToServices(forceRefresh: true),
      ]);
    } catch (e) {
      _setError('Failed to refresh data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  Future<void> _loadLocationData() async {
    try {
      _locationLabel = await _repository.getSavedLocationLabel();
      _address = await _repository.getSavedLocationAddress();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location data: $e');
    }
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    try {
      _categories = await _repository.getCategories(forceRefresh: forceRefresh);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadMostUsedServices({bool forceRefresh = false}) async {
    try {
      _mostUsedServices = await _repository.getMostUsedServices(forceRefresh: forceRefresh);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading most used services: $e');
    }
  }

  Future<void> _loadGoToServices({bool forceRefresh = false}) async {
    try {
      // TODO: Replace with API call when available
      _goToServices = [
        {
          'title': 'Beauty & Wellness (Men)',
          'subtitle': '10 services',
          'images': ['assets/m1.webp', 'assets/m2.webp', 'assets/m3.webp', 'assets/m4.webp'],
        },
        {
          'title': 'Appliance and Repair',
          'subtitle': '4 services',
          'images': ['assets/a1.webp', 'assets/a2.webp', 'assets/a3.webp', 'assets/a4.webp'],
        },
        {
          'title': 'Carpenter & Plumber',
          'subtitle': '2 services',
          'images': ['assets/c1.webp', 'assets/c2.webp', 'assets/c3.webp', 'assets/c4.webp'],
        },
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading go-to services: $e');
    }
  }

  // Update location
  Future<void> updateLocation(String label, String address) async {
    try {
      await _repository.updateLocation(label, address);
      _locationLabel = label;
      _address = address;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update location: ${e.toString()}');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
