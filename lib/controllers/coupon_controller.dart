import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/coupon_models.dart';
import '../data/repository/coupon_repository.dart';

class CouponController extends GetxController {
  final CouponRepository repo;
  CouponController({required this.repo});

  var coupons = <Coupon>[].obs;
  var isLoading = false.obs;
  var selectedCoupon = Rxn<Coupon>();

  /// Helper for beautiful, consistent snackbars
  void _showStyledSnackbar({
    required String title,
    required String message,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bgColor,
      colorText: textColor,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      margin: const EdgeInsets.all(15),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  Future<void> fetchCoupons(String categoryId) async {
    try {
      isLoading.value = true;
      
      // ✅ CRITICAL FIX: Clear old coupons before fetching new ones
      // This prevents coupons from "Male Salon" appearing while loading "Female Salon"
      selectedCoupon.value = null;
      coupons.clear(); 
      
      final fetchedList = await repo.getCoupons(categoryId);
      coupons.value = fetchedList;
      
    } catch (e) {
      debugPrint("Silent fetch error: $e");
      // Optional: Clear list on error to avoid showing stale data
      coupons.clear(); 
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Changed return type from Future<void> to Future<bool>
  Future<bool> applyCoupon(Coupon coupon, double total, String categoryId) async {
    // 1. Client-Side Eligibility Check
    if (total < coupon.minPurchaseAmount) {
      final deficit = (coupon.minPurchaseAmount - total).toInt();
      _showStyledSnackbar(
        title: "Just a bit more!",
        message: "Add ₹$deficit more to unlock this offer.",
        bgColor: Colors.orange.shade50,
        textColor: Colors.orange.shade900,
        icon: Icons.shopping_basket_outlined,
      );
      return false; // ✅ Return false for ineligibility
    }

    try {
      isLoading.value = true;
      bool isValid = await repo.validateCoupon(
        categoryId: categoryId,
        couponId: coupon.id,
        code: coupon.couponCode,
        total: total,
      );

      if (isValid) {
        selectedCoupon.value = coupon;
        
        _showStyledSnackbar(
          title: "Offer Applied!",
          message: "You've saved big with '${coupon.couponCode}'",
          bgColor: Colors.green.shade50,
          textColor: Colors.green.shade900,
          icon: Icons.celebration_outlined,
        );
        return true; // ✅ Return true on successful validation
      } else {
        _showStyledSnackbar(
          title: "Coupon Not Applicable",
          message: "This offer cannot be applied to current items.",
          bgColor: Colors.red.shade50,
          textColor: Colors.red.shade900,
          icon: Icons.info_outline,
        );
        return false; // ✅ Return false on invalid validation
      }
    } catch (e) {
      // 🌐 Handling Internet/Server errors during validation
      _showStyledSnackbar(
        title: "Connection Issue",
        message: "We couldn't verify the coupon. Please try again.",
        bgColor: Colors.grey.shade900,
        textColor: Colors.white,
        icon: Icons.wifi_off_rounded,
      );
      return false; // ✅ Return false on exception
    } finally {
      isLoading.value = false;
    }
  }

  void removeCoupon() {
    if (selectedCoupon.value == null) return;
    
    final code = selectedCoupon.value?.couponCode ?? "";
    selectedCoupon.value = null;
    
    _showStyledSnackbar(
      title: "Coupon Removed",
      message: "Offer '$code' has been removed from your cart.",
      bgColor: Colors.blueGrey.shade50,
      textColor: Colors.blueGrey.shade900,
      icon: Icons.remove_circle_outline,
    );
  }
}