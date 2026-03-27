import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//import '../../../controllers/home_controller.dart';
import '../../../services/MaleSpaScreen.dart';

class MaleSpaSection extends StatelessWidget {
  const MaleSpaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        double titleFontSize = 16.sp * scaleFactor;
        double viewAllFontSize = 14.sp * scaleFactor;
        double cardWidth = 144.w * scaleFactor;
        double cardHeight = 164.h * scaleFactor;
        double labelFontSize = 10.sp * scaleFactor;

        // Static data - can be moved to controller later
        final maleSpaServices = [
          {'imagePath': 'assets/spa_men_swedish.webp', 'label': 'Swedish Massage', 'serviceId': 'sports_recovery_massage'},
          {'imagePath': 'assets/spa_men_backrelief.webp', 'label': 'Back Relief', 'serviceId': 'neck_shoulder_relief'},
          {'imagePath': 'assets/spa_men_bodypolish.webp', 'label': 'Body Polish', 'serviceId': 'deep_tissue_therapy'},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Static title row - no Obx needed
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spa - Men',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => MaleSpaScreen()),
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.r * scaleFactor),
                    child: Text(
                      'View all >',
                      style: TextStyle(
                        fontSize: viewAllFontSize,
                        color: const Color(0xFFFA9441),
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h * scaleFactor),

            // ✅ FIXED: Static content - no Obx needed since using static data
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                itemCount: maleSpaServices.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w * scaleFactor),
                itemBuilder: (context, index) {
                  final item = maleSpaServices[index];
                  return _MaleSpaCard(
                    imagePath: item['imagePath']!,
                    label: item['label']!,
                    serviceId: item['serviceId']!,
                    width: cardWidth,
                    height: cardHeight,
                    labelFontSize: labelFontSize,
                    scaleFactor: scaleFactor,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaleSpaCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String serviceId;
  final double width;
  final double height;
  final double labelFontSize;
  final double scaleFactor;

  const _MaleSpaCard({
    required this.imagePath,
    required this.label,
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
          // ✅ FIXED: Use arguments to pass serviceId
        Get.to(() => MaleSpaScreen(scrollToServiceId: serviceId));

        } catch (e) {
          Get.snackbar(
            'Error',
            'Unable to open spa service',
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
                tag: 'male_spa_$serviceId',
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.spa,
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
                  padding: EdgeInsets.symmetric(
                    vertical: 4.h * scaleFactor,
                    horizontal: 4.w * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9BE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10 * scaleFactor),
                      bottomRight: Radius.circular(10 * scaleFactor),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
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
