import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart';
import '../../models/service_models.dart'; // Updated import to use new model
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/chayan_header.dart';
import '../home/home_screen.dart';
import '../booking/booking_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../chayan_sathi/chayan_sathi_screen.dart';

class CartScreen extends StatelessWidget {
  CartScreen({Key? key}) : super(key: key);

  final CartController cartController = Get.find<CartController>();
  final int _selectedIndex = -2;

  void _onItemTapped(BuildContext context, int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChayanSathiScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ReferAndEarnScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0xFFFFEEE0),
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Container(
            color: const Color(0xFFFFEEE0),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEE0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x26000000),
                            blurRadius: 4 * (isTabletDevice ? scaleFactor : 1.0),
                            offset: Offset(0, 2 * (isTabletDevice ? scaleFactor : 1.0)),
                          )
                        ],
                      ),
                      child: ChayanHeader(
                        title: 'Cart',
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (cartController.isCartEmpty) {
                          return _buildEmptyCart(context, scaleFactor);
                        } else {
                          return _buildCartWithItems(context, scaleFactor);
                        }
                      }),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: (index) => _onItemTapped(context, index),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context, double scaleFactor) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 0.75.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110.w * scaleFactor,
              height: 110.h * scaleFactor,
              child: ClipOval(
                child: SvgPicture.asset(
                  "assets/icons/cart_empty.svg",
                  fit: BoxFit.cover,
                  width: 110.w * scaleFactor,
                  height: 110.h * scaleFactor,
                ),
              ),
            ),
            SizedBox(height: 20.h * scaleFactor),
            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 20.sp * scaleFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h * scaleFactor),
            Opacity(
              opacity: 0.8,
              child: Text(
                'Lets add some services',
                style: TextStyle(
                  fontSize: 20.sp * scaleFactor,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30.h * scaleFactor),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 175.w * scaleFactor,
                height: 45.h * scaleFactor,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                  border: Border.all(
                    color: const Color(0xFFE47830),
                    width: 2.w * scaleFactor,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Explore Services',
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro',
                    color: Color(0xFFE47830),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated: Build cart with grouped items by source - using new CartItem model
  Widget _buildCartWithItems(BuildContext context, double scaleFactor) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final groupedItems = cartController.getItemsGroupedBySource();
            final sourceKeys = groupedItems.keys.toList();
            
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 16.h * scaleFactor),
              itemCount: sourceKeys.length,
              itemBuilder: (context, groupIndex) {
                final sourceTitle = sourceKeys[groupIndex];
                final items = groupedItems[sourceTitle]!; // Items are already sorted by controller
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSourceHeader(sourceTitle, items, scaleFactor),
                    ...items.map((item) => _buildCartItemCard(context, item, scaleFactor)).toList(),
                    if (groupIndex < sourceKeys.length - 1)
                      SizedBox(height: 16.h * scaleFactor),
                  ],
                );
              },
            );
          }),
        ),
        _buildCartSummary(context, scaleFactor),
      ],
    );
  }

  Widget _buildSourceHeader(
      String sourceTitle, List<CartItem> items, double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 16.w * scaleFactor, vertical: 12.h * scaleFactor),
      child: Text(
        sourceTitle,
        style: TextStyle(
          fontSize: 18.sp * scaleFactor,
          fontWeight: FontWeight.w700,
          fontFamily: 'SF Pro',
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Updated: Use new CartItem model properties
  Widget _buildCartItemCard(
      BuildContext context, CartItem cartItem, double scaleFactor) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 16.w * scaleFactor, vertical: 4.h * scaleFactor),
      padding: EdgeInsets.all(16.r * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6 * scaleFactor,
            offset: Offset(0, 2 * scaleFactor),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8 * scaleFactor),
            child: Image.network(  // Changed to Image.network for API images
              cartItem.image,
              width: 70.w * scaleFactor,
              height: 70.h * scaleFactor,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70.w * scaleFactor,
                height: 70.h * scaleFactor,
                color: Colors.grey[300],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[500],
                  size: 30 * scaleFactor,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 70.w * scaleFactor,
                  height: 70.h * scaleFactor,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE47830),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 16.w * scaleFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.name,  // Updated property name
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h * scaleFactor),
                // Updated: Use new model properties
                if (cartItem.rating.isNotEmpty && cartItem.duration.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16 * scaleFactor,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w * scaleFactor),
                      Text(
                        '${cartItem.rating} | ${cartItem.duration}',
                        style: TextStyle(
                          fontSize: 13.sp * scaleFactor,
                          color: Colors.grey[600],
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8.h * scaleFactor),
                Row(
                  children: [
                    Text(
                      cartItem.formattedPrice,  // Use getter from new model
                      style: TextStyle(
                        fontSize: 18.sp * scaleFactor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro',
                        color: const Color(0xFFE47830),
                      ),
                    ),
                    // Updated: Show original price if there's a discount
                    if (cartItem.hasDiscount) ...[
                      SizedBox(width: 8.w * scaleFactor),
                      Text(
                        '₹${cartItem.originalPrice.toInt()}',
                        style: TextStyle(
                          fontSize: 14.sp * scaleFactor,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ],
                  ],
                ),
                // Updated: Use new model description
                if (cartItem.description.isNotEmpty) ...[
                  SizedBox(height: 6.h * scaleFactor),
                  Text(
                    cartItem.description,
                    style: TextStyle(
                      fontSize: 12.sp * scaleFactor,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => cartController.decrementQuantity(cartItem.id),
                      child: Container(
                        width: 32.w * scaleFactor,
                        height: 32.h * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6 * scaleFactor),
                            bottomLeft: Radius.circular(6 * scaleFactor),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18 * scaleFactor,
                          color: const Color(0xFFE47830),
                        ),
                      ),
                    ),
                    Container(
                      width: 40.w * scaleFactor,
                      height: 32.h * scaleFactor,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: TextStyle(
                          fontSize: 14.sp * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE47830),
                          fontFamily: 'SF Pro',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cartController.incrementQuantity(cartItem.id),
                      child: Container(
                        width: 32.w * scaleFactor,
                        height: 32.h * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6 * scaleFactor),
                            bottomRight: Radius.circular(6 * scaleFactor),
                          ),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18 * scaleFactor,
                          color: const Color(0xFFE47830),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, double scaleFactor) {
    return Container(
      padding: EdgeInsets.all(16.w * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6 * scaleFactor,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    cartController.formattedItemCount,
                    style: TextStyle(
                      fontSize: 14.sp * scaleFactor,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'SF Pro',
                      color: Colors.black87,
                    ),
                  )),
                  SizedBox(height: 2.h * scaleFactor),
                  Obx(() {
                    final groupedItems = cartController.getItemsGroupedBySource();
                    return Text(
                      'From ${groupedItems.length} ${groupedItems.length == 1 ? 'source' : 'sources'}',
                      style: TextStyle(
                        fontSize: 12.sp * scaleFactor,
                        color: Colors.grey[600],
                        fontFamily: 'SF Pro',
                      ),
                    );
                  }),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 12.sp * scaleFactor,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro',
                    ),
                  ),
                  Obx(() => Text(
                    cartController.formattedTotalPrice,
                    style: TextStyle(
                      fontSize: 22.sp * scaleFactor,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro',
                      color: const Color(0xFFE47830),
                    ),
                  )),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h * scaleFactor),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showClearCartDialog(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Clear Cart',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'SF Pro',
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w * scaleFactor),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _proceedToCheckout(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE47830),
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE47830).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SF Pro',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Clear Cart',
      middleText: 'Are you sure you want to remove all items from your cart?',
      textCancel: 'Cancel',
      textConfirm: 'Clear All',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey,
      onConfirm: () {
        cartController.clearCart();
        Get.back();
      },
    );
  }

  // Updated: Use new cart validation and checkout methods
  void _proceedToCheckout(BuildContext context) {
    // Use the updated validation method
    cartController.validateCartForCheckout().then((isValid) {
      if (!isValid) return;

      final groupedItems = cartController.getItemsGroupedBySource();

      Get.defaultDialog(
        title: 'Confirm Order',
        content: Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              SizedBox(height: 12),
              ...groupedItems.entries.map((entry) {
                final sourceTitle = entry.key;
                final items = entry.value;
                final itemCount = items.fold(0, (sum, item) => sum + item.quantity);
                final sourceTotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
                
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$sourceTitle ($itemCount ${itemCount == 1 ? 'item' : 'items'})',
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${sourceTotal.toInt()}',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${cartController.formattedItemCount}',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    cartController.formattedTotalPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE47830),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Proceed to payment?',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        textCancel: 'Review Cart',
        textConfirm: 'Pay Now',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFE47830),
        cancelTextColor: Colors.grey,
        onConfirm: () async {
          Get.back();
          Get.dialog(
            Center(child: CircularProgressIndicator(color: Color(0xFFE47830))),
            barrierDismissible: false,
          );
          
          await Future.delayed(Duration(seconds: 2));
          Get.back();
          
          // Use the updated checkout method
          await cartController.completeCheckout();
        },
      );
    });
  }
}
