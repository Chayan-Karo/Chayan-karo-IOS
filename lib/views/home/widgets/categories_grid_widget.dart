import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../services/saloonservicescreen.dart';
import '../../../services/SalonMenServiceScreen.dart';
import '../../../services/HairSkinScreen.dart';
import '../../../services/MaleSpaScreen.dart';
import '../../../services/ACServicesScreen.dart';
import '../../../services/CleaningScreen.dart';
import '../../../services/HomeRepairsScreen.dart';
import '../../../services/FemaleSpaScreen.dart';

class CategoriesGridWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const CategoriesGridWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  void _navigateToService(String title) {
    switch (title) {
      case 'Female Saloon':
        Get.to(() => SalonServiceScreen());
        break;
      case 'Male Saloon':
        Get.to(() => SalonMenServiceScreen());
        break;
      case 'Female Spa':
        Get.to(() => FemaleSpaScreen());
        break;
      case 'Male Spa':
        Get.to(() => MaleSpaScreen());
        break;
      case 'Hair & Skin':
        Get.to(() => HairSkinScreen());
        break;
      case 'Home Repairs':
        Get.to(() => HomeRepairsScreen());
        break;
      case 'Cleaning':
        Get.to(() => CleaningScreen());
        break;
      case 'AC Services':
        Get.to(() => ACServicesScreen());
        break;
      default:
        Get.snackbar(
          'Coming Soon',
          'Service "$title" coming soon!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF6F00),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final homeController = Get.find<HomeController>();
      final categories = homeController.categories;

      // Show loading state
      if (homeController.isLoading && categories.isEmpty) {
        return Container(
          height: 200.h * scaleFactor,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF6F00),
            ),
          ),
        );
      }

      // Show empty state
      if (categories.isEmpty) {
        return Container(
          height: 200.h * scaleFactor,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Center(
            child: Text(
              'No categories available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      // Display categories grid
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 14.h * scaleFactor,
            crossAxisSpacing: 12.w * scaleFactor,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (_, index) {
            final category = categories[index];
            
            return GestureDetector(
              onTap: () => _navigateToService(category.title),
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.w * scaleFactor,
                      color: const Color(0xFFFFD9BE),
                    ),
                    borderRadius: BorderRadius.circular(10 * scaleFactor),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0xFFF2C4A5),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category icon with error handling
                      SvgPicture.asset(
                        category.icon,
                        width: 40.w * scaleFactor,
                        height: 40.h * scaleFactor,
                        placeholderBuilder: (_) => Container(
                          width: 40.w * scaleFactor,
                          height: 40.h * scaleFactor,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6F00).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category,
                            color: const Color(0xFFFF6F00),
                            size: 24.sp * scaleFactor,
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h * scaleFactor),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w * scaleFactor,
                        ),
                        child: Text(
                          category.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9.sp * scaleFactor,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
