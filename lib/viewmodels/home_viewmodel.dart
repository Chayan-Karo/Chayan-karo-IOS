import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repository/home_repository.dart';
import '../models/home_models.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _homeRepository;
  final SharedPreferences _sharedPreferences;

  HomeViewModel({
    required HomeRepository homeRepository,
    required SharedPreferences sharedPreferences,
  })  : _homeRepository = homeRepository,
        _sharedPreferences = sharedPreferences;

  // State variables
  String _address = 'Fetching location...';
  String _locationLabel = 'Home';
  bool _isLoading = false;

  // Data from repository
  List<ServiceCategory> _categories = [];
  List<GoToService> _goToServices = [];
  List<Service> _mostUsedServices = [];

  // Getters
  String get address => _address;
  String get locationLabel => _locationLabel;
  bool get isLoading => _isLoading;
  List<ServiceCategory> get categories => _categories;
  List<GoToService> get goToServices => _goToServices;
  List<Service> get mostUsedServices => _mostUsedServices;

  // Static data (for sections not yet implemented with API)
  final List<Map<String, String>> acRepairItems = [
    {'imagePath': 'assets/ac_services.webp', 'title': 'AC Services'},
    {'imagePath': 'assets/ac_repair.webp', 'title': 'AC Repair & Gas Refill'},
    {'imagePath': 'assets/ac_installation.webp', 'title': 'AC Installation'},
    {'imagePath': 'assets/ac_uninstallation.webp', 'title': 'AC Uninstallation'},
  ];

  // Keep other static data as is until we implement their APIs...

  // Initialize
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadSavedAddress(),
      _loadCategories(),
      _loadGoToServices(),
      _loadMostUsedServices(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  // Load data from repository
  Future<void> _loadCategories() async {
    try {
      _categories = await _homeRepository.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadGoToServices() async {
    try {
      _goToServices = await _homeRepository.getGoToServices();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading goto services: $e');
    }
  }

  Future<void> _loadMostUsedServices() async {
    try {
      _mostUsedServices = await _homeRepository.getMostUsedServices();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading most used services: $e');
    }
  }

  // Load saved address from SharedPreferences
  Future<void> _loadSavedAddress() async {
    try {
      _locationLabel = _sharedPreferences.getString('location_label') ?? 'Home';
      _address = _sharedPreferences.getString('location_address') ?? 'Not Available';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  // Update location
  Future<void> updateLocation(String label, String address) async {
    try {
      await _sharedPreferences.setString('location_label', label);
      await _sharedPreferences.setString('location_address', address);

      _locationLabel = label;
      _address = address;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
}
