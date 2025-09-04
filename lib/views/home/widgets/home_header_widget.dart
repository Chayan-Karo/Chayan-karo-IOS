import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../cart/cart_screen.dart';
import '../../../services/SearchScreen.dart';

class HomeHeaderWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const HomeHeaderWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xFFFFEEE0),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Container(
      color: const Color(0xFFFFEEE0),
      padding: EdgeInsets.only(bottom: 16.r * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location + Cart Row
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12.h * scaleFactor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location Section with Obx
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/homy.svg',
                        width: 40.w * scaleFactor,
                        height: 40.h * scaleFactor,
                        color: Colors.black,
                        // Add error handling
                        placeholderBuilder: (_) => Icon(
                          Icons.home,
                          size: 40.w * scaleFactor,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w * scaleFactor),
                      Expanded(
                        child: Obx(() {
                          final homeController = Get.find<HomeController>();
                          String cityOnly = '';
                          if (homeController.address.contains(',')) {
                            cityOnly = homeController.address.split(',').last.trim();
                          } else {
                            cityOnly = homeController.address.trim();
                          }

                          return GestureDetector(
                            onTap: () {
                              // Handle location selection
                              Get.snackbar(
                                'Location',
                                'Location selection coming soon!',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFF6F00),
                                colorText: Colors.white,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  homeController.locationLabel,
                                  style: TextStyle(
                                    fontSize: 12.sp * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF6F00),
                                  ),
                                ),
                                Text(
                                  cityOnly,
                                  style: TextStyle(
                                    fontSize: 11.sp * scaleFactor,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: 12.w * scaleFactor),
                
                // Cart icon with separate Obx
                Obx(() {
                  final cartController = Get.find<CartController>();
                  
                  return GestureDetector(
                    onTap: () => Get.to(() =>  CartScreen()),
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/cart.svg',
                          width: 40.w * scaleFactor,
                          height: 40.h * scaleFactor,
                          color: Colors.black,
                          // Add error handling
                          placeholderBuilder: (_) => Icon(
                            Icons.shopping_cart,
                            size: 40.w * scaleFactor,
                            color: Colors.black,
                          ),
                        ),
                        // Cart badge
                        if (cartController.cartItemCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(4 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10 * scaleFactor),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18 * scaleFactor,
                                minHeight: 18 * scaleFactor,
                              ),
                              child: Text(
                                '${cartController.cartItemCount}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Search bar (no Obx needed - static content)
          GestureDetector(
            onTap: () => Get.to(() => SearchScreen()),
            child: AbsorbPointer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  height: 48.h * scaleFactor,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F6F2),
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w * scaleFactor),
                        child: Icon(
                          Icons.search,
                          size: 20 * scaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Search for services',
                          style: TextStyle(
                            fontSize: 14.sp * scaleFactor,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
