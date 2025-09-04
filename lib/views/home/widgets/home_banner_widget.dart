import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';

class HomeBannerWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const HomeBannerWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Obx(() {
        final homeController = Get.find<HomeController>();
        
        // Only show loading for banner if controller is loading
        if (homeController.isLoading) {
          return Container(
            height: 120.h * scaleFactor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scaleFactor),
              color: Colors.grey[300],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6F00),
              ),
            ),
          );
        }

        // Static banner content (can be made dynamic later)
        return _buildBannerContent();
      }),
    );
  }

  Widget _buildBannerContent() {
    const bannerTitle = "Let's make a package just\nfor you, Manvi!";
    const bannerSubtitle = "Salon for women";
    const bannerImage = 'assets/banner_woman.webp';

    return GestureDetector(
      onTap: () {
        // Navigate to women salon services
        Get.snackbar(
          'Redirecting',
          'Redirecting to Women Salon Services...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF6F00),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      },
      child: Container(
        height: 120.h * scaleFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8F39), Color(0xFFFF6F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6F00).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w * scaleFactor,
                  vertical: 12.h * scaleFactor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bannerTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h * scaleFactor),
                    Row(
                      children: [
                        Text(
                          bannerSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp * scaleFactor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 6.w * scaleFactor),
                        Icon(
                          Icons.arrow_forward,
                          size: 16.sp * scaleFactor,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.r * scaleFactor),
                bottomRight: Radius.circular(12.r * scaleFactor),
              ),
              child: Image.asset(
                bannerImage,
                height: 120.h * scaleFactor,
                width: 100.w * scaleFactor,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120.h * scaleFactor,
                    width: 100.w * scaleFactor,
                    color: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white.withOpacity(0.7),
                      size: 32.sp * scaleFactor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
