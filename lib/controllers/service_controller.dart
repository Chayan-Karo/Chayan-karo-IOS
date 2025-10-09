// lib/controllers/service_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/repository/service_repository.dart';
import '../models/service_models.dart';

class ServiceController extends GetxController {
  // Singleton repository
  final ServiceRepository _serviceRepository = ServiceRepository();

  // Reactive variables
  final RxList<Service> _services = <Service>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _currentServiceCategoryId = ''.obs;

  // Getters
  List<Service> get services => _services;
  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    print('🔧 ServiceController initialized');
  }

  @override
  void onReady() {
    super.onReady();
    print('🔧 ServiceController ready');
  }

  Future<void> loadServices(String serviceCategoryId) async {
    if (_currentServiceCategoryId.value == serviceCategoryId && _services.isNotEmpty) {
      return; // Already loaded
    }

    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';
    _currentServiceCategoryId.value = serviceCategoryId;

    try {
      print('🔄 Loading services for category: $serviceCategoryId');
      
      final services = await _serviceRepository.getServices(serviceCategoryId);
      _services.assignAll(services);
      
      print('✅ Loaded ${_services.length} services');
      
      if (services.isEmpty) {
        _errorMessage.value = 'No services available for this category';
      }
    } catch (e) {
      print('❌ Error loading services: $e');
      _hasError.value = true;
      _errorMessage.value = 'Failed to load services: ${e.toString()}';
      
      Get.snackbar(
        'Error',
        'Failed to load services. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh services
  Future<void> refreshServices() async {
    if (_currentServiceCategoryId.value.isEmpty) return;
    
    print('🔄 Refreshing services for category: ${_currentServiceCategoryId.value}');
    _hasError.value = false;
    _errorMessage.value = '';

    try {
      final services = await _serviceRepository.refreshServices(_currentServiceCategoryId.value);
      _services.assignAll(services);
      
      print('✅ Services refreshed successfully: ${services.length}');
      
      Get.snackbar(
        'Success',
        'Services updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error refreshing services: $e');
      _hasError.value = true;
      _errorMessage.value = 'Failed to refresh services: ${e.toString()}';
      
      Get.snackbar(
        'Refresh Failed',
        'Could not refresh services. Please check your connection.',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void retry() {
    if (_currentServiceCategoryId.value.isNotEmpty) {
      loadServices(_currentServiceCategoryId.value);
    }
  }

  void clearServices() {
    _services.clear();
    _currentServiceCategoryId.value = '';
    _hasError.value = false;
    _errorMessage.value = '';
  }

  Service? getServiceById(String serviceId) {
    return _services.firstWhereOrNull((service) => service.id == serviceId);
  }

  List<Service> searchServices(String query) {
    if (query.isEmpty) return _services;
    
    return _services.where((service) =>
        service.name.toLowerCase().contains(query.toLowerCase()) ||
        service.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Navigate to service details
  void navigateToServiceDetails(String serviceId) {
    final service = getServiceById(serviceId);
    if (service != null) {
      Get.toNamed('/service-details', arguments: {
        'service': service,
        'serviceId': serviceId,
      });
    } else {
      Get.snackbar(
        'Error',
        'Service not found',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}
