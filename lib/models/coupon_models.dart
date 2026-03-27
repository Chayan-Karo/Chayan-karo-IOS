class ValidateCouponResponse {
  final String? type;
  final String? result; // ✅ Changed dynamic to String based on your log

  ValidateCouponResponse({this.type, this.result});

  factory ValidateCouponResponse.fromJson(Map<String, dynamic> json) {
    return ValidateCouponResponse(
      type: json['type']?.toString(),
      result: json['result']?.toString(),
    );
  }

  /// ✅ Logic to determine if the coupon is valid based on your specific API response
  bool get isValid {
    final t = type?.toLowerCase() ?? '';
    final r = result?.toLowerCase() ?? '';
    
    // Successful if type contains 'validate' AND result contains 'success'
    return t.contains('validate') && r.contains('success');
  }
}

class CouponResponse {
  final String? type;
  final List<Coupon>? result;

  CouponResponse({this.type, this.result});

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      type: json['type'],
      result: json['result'] != null 
          ? (json['result'] as List).map((i) => Coupon.fromJson(i)).toList() 
          : null,
    );
  }
}

class Coupon {
  final String id;
  final String couponCode;
  final String discountType; // "PERCENTAGE" or "FLAT"
  final double amount;
  final double minPurchaseAmount;
  final int discountPercentage;
  final bool isActive;

  Coupon({
    required this.id,
    required this.couponCode,
    required this.discountType,
    required this.amount,
    required this.minPurchaseAmount,
    required this.discountPercentage,
    required this.isActive,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse any number to double
    double toDouble(dynamic val) {
      if (val is num) return val.toDouble();
      return 0.0;
    }

    return Coupon(
      id: json['id']?.toString() ?? '',
      couponCode: json['couponCode']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'FLAT',
      amount: toDouble(json['amount']),
      minPurchaseAmount: toDouble(json['minPurchaseAmount']),
      // ✅ API log shows 10.0 for percentage, we convert to int safely
      discountPercentage: toDouble(json['discountPercentage']).toInt(),
      isActive: json['isActive'] ?? false,
    );
  }

  /// ✅ Improved description getter for the UI
  String get description {
    if (discountType == "PERCENTAGE") {
      return "Get $discountPercentage% off above ₹${minPurchaseAmount.toInt()}";
    }
    return "Flat ₹${amount.toInt()} off above ₹${minPurchaseAmount.toInt()}";
  }
}