import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart';
import '../data/local/database.dart';
import '../models/service_models.dart';

class CartController extends GetxController {
  final AppDatabase _database = Get.find();

  // Observable map to store cart items using CartItem from service_models
  var _items = <String, CartItem>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDb();
    // Listen to changes and save automatically
    ever(_items, (_) => _saveToDb());
  }

  // Load cart items from database - UPDATED to use correct database method
  Future<void> _loadFromDb() async {
    try {
      // Use getAllNewCartItems() to get service_models.CartItem objects
      final items = await _database.getAllNewCartItems();
      _items.value = {for (var item in items) item.id: item};
      print('✅ Loaded ${_items.length} items from database');
    } catch (e) {
      print('❌ Error loading cart from database: $e');
      // Fallback: try to load and convert legacy cart items
      try {
        final legacyItems = await _database.getAllCartItems();
        final convertedItems = <String, CartItem>{};
        
        for (var legacyItem in legacyItems) {
          // Convert legacy cart item to new cart item
          final cartItem = CartItem(
            id: legacyItem.id,
            name: legacyItem.title, // Use title as name for legacy items
            price: legacyItem.price,
            originalPrice: double.tryParse(legacyItem.originalPrice ?? '0') ?? legacyItem.price,
            image: legacyItem.image,
            duration: legacyItem.duration ?? '',
            rating: legacyItem.rating ?? '0.0',
            description: legacyItem.description ?? '',
            discountPercentage: 0, // Default for legacy items
            sourcePage: legacyItem.sourcePage ?? 'unknown',
            sourceTitle: legacyItem.sourceTitle ?? 'Unknown Service',
            quantity: legacyItem.quantity,
            dateAdded: legacyItem.dateAdded,
          );
          convertedItems[cartItem.id] = cartItem;
        }
        
        _items.value = convertedItems;
        print('✅ Converted ${convertedItems.length} legacy items');
      } catch (legacyError) {
        print('❌ Error loading legacy cart items: $legacyError');
      }
    }
  }

  // Save cart items to database - UPDATED to use correct method
  Future<void> _saveToDb() async {
    try {
      for (final item in _items.values) {
        await _database.insertOrUpdateCartItem(item);
      }
    } catch (e) {
      print('❌ Error saving cart to database: $e');
    }
  }

  // Core getters
  List<CartItem> get cartItems {
    final items = _items.values.toList();
    items.sort((a, b) => b.quantity.compareTo(a.quantity)); // Sort by quantity desc
    return items;
  }

  bool get isCartEmpty => _items.isEmpty;
  int get cartItemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  int getQuantity(String id) => _items[id]?.quantity ?? 0;
  bool isInCart(String id) => _items.containsKey(id);

  // Add service to cart (simplified for single dynamic page)
  void addServiceToCart(Service service, {String? sourcePage, String? sourceTitle}) {
    if (_items.containsKey(service.id)) {
      incrementQuantity(service.id);
    } else {
      final cartItem = service.toCartItem(
        sourcePage: sourcePage ?? 'category_service',
        sourceTitle: sourceTitle ?? 'Services',
      );
      _items[service.id] = cartItem;
    }
    _showCartFeedback('${service.name} added to cart');
  }

  // Increment quantity
  void incrementQuantity(String id) {
    if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: _items[id]!.quantity + 1);
    }
  }

  // Decrement quantity
  Future<void> decrementQuantity(String id) async {
    if (_items.containsKey(id)) {
      final currentQty = _items[id]!.quantity;
      if (currentQty > 1) {
        _items[id] = _items[id]!.copyWith(quantity: currentQty - 1);
      } else {
        await removeService(id);
      }
    }
  }

  // Update quantity directly
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await removeService(id);
    } else if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: quantity);
    }
  }

  // Remove service from cart
  Future<void> removeService(String id) async {
    final service = _items[id];
    if (service != null) {
      _items.remove(id);
      await _database.removeCartItem(id);
      _showCartFeedback('${service.name} removed from cart');
      refreshCart();
    }
  }

  // Clear entire cart - UPDATED to use correct database method
  Future<void> clearCart() async {
    _items.clear();
    await _database.clearAllCartItems();
    _showCartFeedback('Cart cleared');
    refreshCart();
  }

  // Manual refresh
  void refreshCart() {
    _items.refresh();
  }

  // Get cart item by ID
  CartItem? getCartItem(String id) => _items[id];

  // Formatted getters
  String get formattedTotalPrice => '₹${totalPrice.toInt()}';
  String get formattedItemCount {
    final count = cartItemCount;
    return count == 1 ? '$count item' : '$count items';
  }

  // Cart summary for UI
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': cartItemCount,
      'totalPrice': totalPrice,
      'formattedTotalPrice': formattedTotalPrice,
      'formattedItemCount': formattedItemCount,
      'hasItems': !isCartEmpty,
    };
  }

  // Get items grouped by source (method name matches cart screen usage)
  Map<String, List<CartItem>> getItemsGroupedBySource() {
    Map<String, List<CartItem>> grouped = {};
    
    for (var item in cartItems) {
      String sourceKey = item.sourceTitle;
      if (!grouped.containsKey(sourceKey)) {
        grouped[sourceKey] = [];
      }
      grouped[sourceKey]!.add(item);
    }
    
    return grouped;
  }

  // Keep the original method name for backward compatibility
  Map<String, List<CartItem>> getItemsGroupedByCategory() {
    return getItemsGroupedBySource();
  }

  // Checkout process
  Future<bool> validateCartForCheckout() async {
    if (isCartEmpty) {
      _showCartFeedback('Cart is empty');
      return false;
    }
    
    // Additional validation
    for (var item in _items.values) {
      if (item.price <= 0) {
        _showCartFeedback('Invalid item price found');
        return false;
      }
      if (item.quantity <= 0) {
        _showCartFeedback('Invalid item quantity found');
        return false;
      }
    }
    
    return true;
  }

  Future<void> completeCheckout() async {
    if (await validateCartForCheckout()) {
      // Show processing state
      Get.snackbar(
        'Processing Order',
        'Processing ${cartItemCount} items worth ${formattedTotalPrice}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFE47830),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      
      // Simulate processing time
      await Future.delayed(Duration(seconds: 2));
      
      // Clear cart after successful checkout
      await clearCart();
      
      // Show success message
      Get.snackbar(
        'Order Placed',
        'Your order has been placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Utility methods
  void _showCartFeedback(String message) {
    Get.snackbar(
      'Cart Update',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Color(0xFFE47830),
      colorText: Colors.white,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  // Force reload from database
  Future<void> forceRefreshFromDb() async {
    await _loadFromDb();
    refreshCart();
  }

  // Get cart statistics
  Map<String, dynamic> getCartStats() {
    final groupedItems = getItemsGroupedBySource();
    return {
      'totalItems': cartItemCount,
      'uniqueItems': _items.length,
      'totalPrice': totalPrice,
      'averageItemPrice': _items.isEmpty ? 0.0 : totalPrice / cartItemCount,
      'categories': groupedItems.keys.toList(),
      'categoryCount': groupedItems.length,
      'mostExpensiveItem': _items.isEmpty ? null : _items.values.reduce((a, b) => a.price > b.price ? a : b),
      'cheapestItem': _items.isEmpty ? null : _items.values.reduce((a, b) => a.price < b.price ? a : b),
      'hasDiscounts': _items.values.any((item) => item.hasDiscount),
      'totalSavings': _items.values.fold(0.0, (sum, item) => sum + item.totalSavings),
    };
  }

  // ADDED: Get cart items by source
  List<CartItem> getCartItemsBySource(String sourcePage) {
    return _items.values
        .where((item) => item.sourcePage == sourcePage)
        .toList();
  }

  // ADDED: Get total items for specific source
  int getSourceItemCount(String sourcePage) {
    return _items.values
        .where((item) => item.sourcePage == sourcePage)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // ADDED: Get total price for specific source
  double getSourceTotalPrice(String sourcePage) {
    return _items.values
        .where((item) => item.sourcePage == sourcePage)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ADDED: Check if service exists in cart
  bool hasService(String serviceId) => _items.containsKey(serviceId);

  // ADDED: Get cart item by service ID (alias for getCartItem)
  CartItem? getCartItemByServiceId(String serviceId) => getCartItem(serviceId);

  // ADDED: Get formatted cart summary for UI display
  String getCartDisplaySummary() {
    if (isCartEmpty) return 'Cart is empty';
    
    final stats = getCartStats();
    final sources = stats['categoryCount'] as int;
    
    return '$formattedItemCount from $sources ${sources == 1 ? 'source' : 'sources'} • $formattedTotalPrice';
  }

  // ADDED: Check if cart has items from multiple sources
  bool get hasMultipleSources => getItemsGroupedBySource().length > 1;

  // ADDED: Get total savings across all items
  double get totalSavings => _items.values.fold(0.0, (sum, item) => sum + item.totalSavings);

  // ADDED: Get formatted total savings
  String get formattedTotalSavings {
    final savings = totalSavings;
    return savings > 0 ? '₹${savings.toInt()}' : '';
  }

  // ADDED: Check if cart has any discounted items
  bool get hasDiscountedItems => _items.values.any((item) => item.hasDiscount);

  // ADDED: Get most expensive item in cart
  CartItem? get mostExpensiveItem {
    if (_items.isEmpty) return null;
    return _items.values.reduce((a, b) => a.price > b.price ? a : b);
  }

  // ADDED: Get cheapest item in cart
  CartItem? get cheapestItem {
    if (_items.isEmpty) return null;
    return _items.values.reduce((a, b) => a.price < b.price ? a : b);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
