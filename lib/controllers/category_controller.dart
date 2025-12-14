// lib/controllers/category_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../data/repository/category_repository.dart';
import '../models/category_models.dart';

class CategoryController extends GetxController {
  // Singleton repository
  final CategoryRepository _categoryRepository = CategoryRepository();

  // Reactive variables
  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<Category> _filteredCategories = <Category>[].obs;

  // Getters
  List<Category> get categories => _categories;
  List<Category> get filteredCategories => _filteredCategories;
  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  bool get hasError => _errorMessage.value.isNotEmpty;
  bool get hasCategories => _categories.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    print('📂 CategoryController initialized');
    loadCategories();
  }

  @override
  void onReady() {
    super.onReady();
    print('📂 CategoryController ready');
  }

  // Load categories
  Future<void> loadCategories() async {
    if (_isLoading.value) return;
    
    print('📂 Loading categories...');
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final categories = await _categoryRepository.getCategories();
      _categories.assignAll(categories);
      _filteredCategories.assignAll(categories);
      
      print('✅ Categories loaded successfully: ${categories.length}');
      
      if (categories.isEmpty) {
        _errorMessage.value = 'No categories available';
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
      _errorMessage.value = 'Failed to load categories: ${e.toString()}';
      
      Get.snackbar(
        'Error',
        'Failed to load categories. Please try again.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    if (_isRefreshing.value) return;
    
    print('🔄 Refreshing categories...');
    _isRefreshing.value = true;
    _errorMessage.value = '';

    try {
      final categories = await _categoryRepository.refreshCategories();
      _categories.assignAll(categories);
      _applySearchFilter();
      
      print('✅ Categories refreshed successfully: ${categories.length}');
      
      Get.snackbar(
        'Success',
        'Categories updated successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error refreshing categories: $e');
      _errorMessage.value = 'Failed to refresh categories: ${e.toString()}';
      
      Get.snackbar(
        'Refresh Failed',
        'Could not refresh categories. Please check your connection.',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isRefreshing.value = false;
    }
  }

  // Search categories
  void searchCategories(String query) {
    _searchQuery.value = query;
    _applySearchFilter();
  }

  // Apply search filter
  void _applySearchFilter() {
    if (_searchQuery.value.isEmpty) {
      _filteredCategories.assignAll(_categories);
    } else {
      final filtered = _categories.where((category) =>
        category.categoryName.toLowerCase().contains(_searchQuery.value.toLowerCase())
      ).toList();
      _filteredCategories.assignAll(filtered);
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _filteredCategories.assignAll(_categories);
  }

  // Get category by ID
  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere(
        (category) => category.categoryId == categoryId,
      );
    } catch (e) {
      print('❌ Category not found: $categoryId');
      return null;
    }
  }

  // Get service subcategories for a category
  List<ServiceSubCategory> getServiceSubCategories(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.serviceCategory ?? [];
  }

  // Navigate to category details
  void navigateToCategoryDetails(String categoryId) {
    final category = getCategoryById(categoryId);
    if (category != null) {
      Get.toNamed('/category-details', arguments: {
        'category': category,
        'categoryId': categoryId,
      });
    } else {
      Get.snackbar(
        'Error',
        'Category not found',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  // Retry loading
  void retry() {
    loadCategories();
  }
}
