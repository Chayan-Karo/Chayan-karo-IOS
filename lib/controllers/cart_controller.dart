import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:drift/drift.dart';
import '../data/local/database.dart';
import '../models/cart_models.dart' as cart_models;
import '../models/salon_service.dart';
import '../models/male_spa_service.dart';

class CartController extends GetxController {
  final AppDatabase _database = Get.find();

  // Observable map to store cart items
  var _items = <String, cart_models.CartItem>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromDb();
    // Listen to changes in _items and save to database automatically
    ever(_items, (_) => _saveToDb());
  }

  // Load cart items from database on app start
  Future<void> _loadFromDb() async {
    try {
      final items = await _database.getAllCartItems();
      _items.value = {for (var item in items) item.id: item};
    } catch (e) {
      print('Error loading cart from database: $e');
    }
  }

  // FIXED: Save cart items to database with proper timestamp preservation
  Future<void> _saveToDb() async {
    try {
      // Instead of clearing all and re-inserting, use individual operations
      for (final item in _items.values) {
        await _database.insertCartItem(item);
      }
    } catch (e) {
      print('Error saving cart to database: $e');
    }
  }

  // Getters for cart data - FIXED: Sort by dateAdded
  List<cart_models.CartItem> get cartItems {
    final items = _items.values.toList();
    items.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return items;
  }

  bool get isCartEmpty => _items.isEmpty;
  int get cartItemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  int getQuantity(String id) => _items[id]?.quantity ?? 0;
  bool isInCart(String id) => _items.containsKey(id);

  // UPDATED: Accept source information when adding items
  void addItem(dynamic service, {String? sourcePage, String? sourceTitle}) {
    if (_items.containsKey(service.id)) {
      incrementQuantity(service.id);
    } else {
      // Parse price string to handle ₹200 format
      final priceString = service.price.toString().replaceAll(RegExp(r'[^\d.]'), '');
      final price = double.tryParse(priceString) ?? 0;
      
      // Determine service type based on runtime type
      cart_models.ServiceType serviceType = cart_models.ServiceType.general;
      if (service.runtimeType.toString() == 'SalonService') {
        serviceType = cart_models.ServiceType.salon;
      } else if (service.runtimeType.toString() == 'MaleSpaService') {
        serviceType = cart_models.ServiceType.spa;
      }
      
      final newItem = cart_models.CartItem(
        id: service.id,
        title: service.title,
        image: service.image,
        price: price,
        quantity: 1,
        description: service.desc ?? '',
        rating: service.rating ?? '',
        duration: service.duration ?? '',
        originalPrice: service.originalPrice,
        type: serviceType,
        sourcePage: sourcePage,
        sourceTitle: sourceTitle,
        service: service,
        dateAdded: DateTime.now(), // Use current time for new items
      );
      _items[service.id] = newItem;
    }
  }

  // UPDATED: Add source information to service-specific methods
  void addSalonService(SalonService service, {String? sourcePage, String? sourceTitle}) {
    addItem(service, 
      sourcePage: sourcePage ?? 'salon_services',
      sourceTitle: sourceTitle ?? 'Salon for Women'
    );
  }

  void addMaleSpaService(MaleSpaService service, {String? sourcePage, String? sourceTitle}) {
    addItem(service, 
      sourcePage: sourcePage ?? 'spa_services',
      sourceTitle: sourceTitle ?? 'Spa Services'
    );
  }

  // Add item from CartItem object (for loading from database)
  void addCartItem(cart_models.CartItem item) {
    _items[item.id] = item;
  }

  // Increment quantity of existing item - FIXED: Preserve original dateAdded
  void incrementQuantity(String id) {
    if (_items.containsKey(id)) {
      final currentQty = _items[id]!.quantity;
      _items[id] = _items[id]!.copyWith(quantity: currentQty + 1);
      // Don't change dateAdded when incrementing quantity
    }
  }

  // FIXED: Make decrement async to await remove operation
  Future<void> decrementQuantity(String id) async {
    if (_items.containsKey(id)) {
      final currentQty = _items[id]!.quantity;
      if (currentQty > 1) {
        _items[id] = _items[id]!.copyWith(quantity: currentQty - 1);
      } else {
        await removeService(id); // Wait for DB removal
      }
    }
  }

  // FIXED: Make updateQuantity async to await remove operation
  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      await removeService(id); // Wait for DB removal
    } else if (_items.containsKey(id)) {
      _items[id] = _items[id]!.copyWith(quantity: quantity);
    }
  }

  // FIXED: Remove service from both memory and database
  Future<void> removeService(String id) async {
    if (_items.containsKey(id)) {
      _items.remove(id);
      await _database.removeCartItem(id); // Wait for DB removal
      refreshCart();
    }
  }

  // FIXED: Clear both memory and database
  Future<void> clearCart() async {
    _items.clear();
    await _database.clearCart(); // Clear from database too
    refreshCart();
  }

  // Refresh cart manually (triggers UI update)
  void refreshCart() {
    _items.refresh();
  }

  // Get cart item by ID
  cart_models.CartItem? getCartItem(String id) {
    return _items[id];
  }

  // Get formatted total price string
  String get formattedTotalPrice => '₹${totalPrice.toInt()}';

  // Get formatted item count string
  String get formattedItemCount {
    final count = cartItemCount;
    return count == 1 ? '$count item' : '$count items';
  }

  // Check if cart has items of specific type
  bool hasItemsOfType(cart_models.ServiceType type) {
    return _items.values.any((item) => item.type == type);
  }

  // Get items of specific type
  List<cart_models.CartItem> getItemsOfType(cart_models.ServiceType type) {
    return _items.values.where((item) => item.type == type).toList();
  }

  // UPDATED: Get items grouped by source page for display WITH SORTING
  Map<String, List<cart_models.CartItem>> getItemsGroupedBySource() {
    Map<String, List<cart_models.CartItem>> grouped = {};
    
    // Use the sorted cartItems getter
    for (var item in cartItems) {
      String sourceKey = item.sourceTitle ?? item.sourcePage ?? 'General Services';
      if (!grouped.containsKey(sourceKey)) {
        grouped[sourceKey] = [];
      }
      grouped[sourceKey]!.add(item);
    }
    
    // Items are already sorted by dateAdded in cartItems getter
    return grouped;
  }

  List<cart_models.CartItem> getItemsBySourcePage(String sourcePage) {
    return _items.values.where((item) => item.sourcePage == sourcePage).toList();
  }

  List<cart_models.CartItem> getItemsBySourceTitle(String sourceTitle) {
    return _items.values.where((item) => item.sourceTitle == sourceTitle).toList();
  }

  bool hasItemsFromSource(String sourcePage) {
    return _items.values.any((item) => item.sourcePage == sourcePage);
  }

  int getSourceItemCount(String sourcePage) {
    return _items.values
        .where((item) => item.sourcePage == sourcePage)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  double getSourceTotalPrice(String sourcePage) {
    return _items.values
        .where((item) => item.sourcePage == sourcePage)
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': cartItemCount,
      'totalPrice': totalPrice,
      'items': cartItems.map((item) => item.toJson()).toList(),
      'groupedBySource': getItemsGroupedBySource().map(
        (key, value) => MapEntry(key, value.map((item) => item.toJson()).toList())
      ),
    };
  }

  // FIXED: Make completeCheckout async for proper clearCart
  Future<void> completeCheckout() async {
    await Future.delayed(Duration(seconds: 1));
    await clearCart(); // Wait for cart clearing
  }

  bool validateCart() {
    return !isCartEmpty;
  }

  Future<void> forceRefreshFromDb() async {
    await _loadFromDb();
    refreshCart();
  }

  Map<String, dynamic> getCartStats() {
    final salonItems = getItemsOfType(cart_models.ServiceType.salon);
    final spaItems = getItemsOfType(cart_models.ServiceType.spa);
    final generalItems = getItemsOfType(cart_models.ServiceType.general);
    final groupedBySource = getItemsGroupedBySource();
    
    return {
      'totalItems': cartItemCount,
      'uniqueItems': _items.length,
      'totalPrice': totalPrice,
      'salonItems': salonItems.length,
      'spaItems': spaItems.length,
      'generalItems': generalItems.length,
      'averageItemPrice': _items.isEmpty ? 0 : totalPrice / cartItemCount,
      'sourcePages': groupedBySource.keys.toList(),
      'sourceCounts': groupedBySource.map((key, value) => MapEntry(key, value.length)),
    };
  }

  void addServiceFromMap(Map<String, dynamic> serviceMap, {String? sourcePage, String? sourceTitle}) {
    final id = serviceMap['id'] as String;
    final title = serviceMap['title'] as String;
    final image = serviceMap['image'] as String;
    final priceString = serviceMap['price'].toString().replaceAll(RegExp(r'[^\d.]'), '');
    final price = double.tryParse(priceString) ?? 0;
    
    if (_items.containsKey(id)) {
      incrementQuantity(id);
    } else {
      final newItem = cart_models.CartItem(
        id: id,
        title: title,
        image: image,
        price: price,
        quantity: 1,
        description: serviceMap['desc'] ?? '',
        rating: serviceMap['rating'] ?? '',
        duration: serviceMap['duration'] ?? '',
        originalPrice: serviceMap['originalPrice'],
        type: cart_models.ServiceType.general,
        sourcePage: sourcePage,
        sourceTitle: sourceTitle,
        service: null,
        dateAdded: DateTime.now(),
      );
      _items[id] = newItem;
    }
  }

  bool hasService(String serviceId) {
    return _items.containsKey(serviceId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
