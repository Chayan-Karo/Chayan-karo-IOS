import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/repository/profile_repository.dart';
import '../models/customer_models.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepository = Get.find<ProfileRepository>();

  final _customer = Rxn<Customer>();
  final _isLoading = false.obs;
  final _isUploading = false.obs; // NEW: Uploading state
  final _errorMessage = ''.obs;

  Customer? get customer => _customer.value;
  bool get isLoading => _isLoading.value;
  bool get isUploading => _isUploading.value; // NEW: Public getter
  String get errorMessage => _errorMessage.value;

  final ImagePicker _picker = ImagePicker(); // NEW: Image Picker instance

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      final customerData = await _profileRepository.getCustomer();
      _customer.value = customerData;
    } catch (e) {
      _errorMessage.value = _getErrorMessage(e.toString());
      print('❌ Error loading profile: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  Future<bool> updateProfile({
    String? emailId,
    required String fullName,
    required String gender,
  }) async {
    try {
      final names = fullName.trim().split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      await _profileRepository.updateCustomerProfile(
        emailId: emailId?.trim(),
        firstName: firstName,
        lastName: lastName,
        gender: gender,
      );
      await refreshProfile();
      return true;
    } catch (e) {
      _errorMessage.value = _getErrorMessage(e.toString());
      return false;
    }
  }

  // NEW: Method to Pick and Upload Image
  Future<void> pickAndUploadImage() async {
    try {
      // 1. Pick Image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Compress slightly to save bandwidth
        maxWidth: 1024,   // Resize large images to avoid 413 Payload Too Large
      );

      if (pickedFile == null) return; // User canceled selection

      // 2. Set loading state
      _isUploading.value = true;
      File imageFile = File(pickedFile.path);

      // 3. Upload via Repository
      await _profileRepository.uploadProfileImage(imageFile);
      
      // 4. Update local state (refreshProfile is called inside repo, but we ensure UI updates here)
      await refreshProfile();

      Get.snackbar(
        'Success', 
        'Profile picture updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );

    } catch (e) {
      print('❌ Upload Error: $e');
      Get.snackbar(
        'Error', 
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _isUploading.value = false;
    }
  }

  String getStatusText() {
    final status = _customer.value?.status;
    switch (status) {
      case 1:
        return 'Active';
      case 0:
        return 'Inactive';
      case 2:
        return 'Suspended';
      default:
        return 'Unknown';
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Session expired') || error.contains('401')) {
      return 'Session expired. Please login again.';
    } else if (error.contains('No authentication token')) {
      return 'Please login to view your profile.';
    } else if (error.contains('connection') ||
        error.contains('network') ||
        error.contains('SocketException')) {
      return 'Network error. Check your connection.';
    } else if (error.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Failed to load profile. Please try again.';
    }
  }

  bool get needsLogin => _errorMessage.value.contains('login again');

  String get userDisplayName => _customer.value?.displayName ?? 'User';
  String get userPhone => _customer.value?.mobileNo ?? '';
  double get userRating => _customer.value?.averageRating ?? 0.0;
  
  // Correctly points to imageUrl
  String? get userImage => _customer.value?.imageUrl;

  bool get isBasicInfoComplete {
    final c = _customer.value;
    if (c == null) return false;

    String _clean(String? v) => (v ?? '').trim();

    final firstName = _clean(c.firstName);
    final gender = _clean(c.gender);

    if (firstName.isEmpty) return false;
    if (gender.isEmpty) return false;

    return true;
  }
}