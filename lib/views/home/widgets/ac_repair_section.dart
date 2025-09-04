import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../services/ACServicesScreen.dart';

class ACRepairSection extends StatelessWidget {
  const ACRepairSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        double titleFontSize = 16.sp * scaleFactor;
        double viewAllFontSize = 13.sp * scaleFactor;
        double cardWidth = 144.w * scaleFactor;
        double cardHeight = 180.h * scaleFactor;
        double labelFontSize = 10.sp * scaleFactor;
        double spacing = 12.w * scaleFactor;
        double topSpacing = 12.h * scaleFactor;
        double containerHeight = 200.h * scaleFactor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Static section header - no Obx needed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AC Repair',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => ACServicesScreen()),
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.r * scaleFactor),
                    child: Text(
                      'View all >',
                      style: TextStyle(
                        fontSize: viewAllFontSize,
                        color: const Color(0xFFFF6F00),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: topSpacing),

            // ✅ FIXED: Only wrap the content that uses observable variables
            Obx(() {
              final homeController = Get.find<HomeController>();
              
              // Check if AC repair items exist and if loading
              if (homeController.isLoading) {
                return SizedBox(
                  height: containerHeight,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6F00),
                    ),
                  ),
                );
              }

              if (homeController.acRepairItems.isEmpty) {
                return SizedBox(
                  height: containerHeight,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.ac_unit,
                          size: 48 * scaleFactor,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.h * scaleFactor),
                        Text(
                          'No AC services available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16 * scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Scrollable Cards - using observable data
              return SizedBox(
                height: containerHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                  itemCount: homeController.acRepairItems.length,
                  separatorBuilder: (_, __) => SizedBox(width: spacing),
                  itemBuilder: (context, index) {
                    final item = homeController.acRepairItems[index];
                    return _ACRepairCard(
                      imagePath: item['imagePath']!,
                      title: item['title']!,
                      serviceId: 'ac_service_$index',
                      width: cardWidth,
                      height: cardHeight,
                      labelFontSize: labelFontSize,
                      scaleFactor: scaleFactor,
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _ACRepairCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String serviceId;
  final double width;
  final double height;
  final double labelFontSize;
  final double scaleFactor;

  const _ACRepairCard({
    required this.imagePath,
    required this.title,
    required this.serviceId,
    required this.width,
    required this.height,
    required this.labelFontSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          // ✅ FIXED: Using arguments instead of named parameter
          Get.to(() => ACServicesScreen(scrollToServiceId: serviceId));

        } catch (e) {
          Get.snackbar(
            'Error',
            'Unable to open AC service',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          border: Border.all(
            color: const Color(0xFFFFD9BE),
            width: 1.w * scaleFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'ac_service_$serviceId',
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.ac_unit,
                        color: const Color(0xFFFF6F00),
                        size: 32.sp * scaleFactor,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 4.h * scaleFactor,
                    horizontal: 6.h * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9BE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.h * scaleFactor),
                      bottomRight: Radius.circular(10.h * scaleFactor),
                    ),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
