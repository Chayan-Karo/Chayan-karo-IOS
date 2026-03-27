import 'package:get/get.dart';
import '../models/coupon_models.dart';
import '../data/repository/coupon_repository.dart';
import '../widgets/app_snackbar.dart';

class CouponController extends GetxController {
  final CouponRepository repo;
  CouponController({required this.repo});

  var coupons = <Coupon>[].obs;
  var isLoading = false.obs;
  var selectedCoupon = Rxn<Coupon>();


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
      AppSnackbar.showWarning('Add ₹$deficit more to unlock this offer.');
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
        
        AppSnackbar.showSuccess("You've saved big with '${coupon.couponCode}'");
        return true; // ✅ Return true on successful validation
      } else {
        AppSnackbar.showError('This offer cannot be applied to current items.');
        return false; // ✅ Return false on invalid validation
      }
    } catch (e) {
      // 🌐 Handling Internet/Server errors during validation
      AppSnackbar.showError("We couldn't verify the coupon. Please try again.");
      return false; // ✅ Return false on exception
    } finally {
      isLoading.value = false;
    }
  }

  void removeCoupon() {
    if (selectedCoupon.value == null) return;
    
    final code = selectedCoupon.value?.couponCode ?? "";
    selectedCoupon.value = null;
    
    AppSnackbar.showInfo("Offer '$code' has been removed from your cart.");
  }
}