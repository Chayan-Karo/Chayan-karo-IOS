import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../../../services/FemaleSpaScreen.dart';

class SpaWomenSection extends StatelessWidget {
  const SpaWomenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        double titleFontSize = 16.sp * scaleFactor;
        double viewAllFontSize = 13.sp * scaleFactor;
        double cardWidth = 144.w * scaleFactor;
        double cardHeight = 164.h * scaleFactor;
        double labelFontSize = 10.sp * scaleFactor;
        double spacing = 12.w * scaleFactor;
        double topSpacing = 12.h * scaleFactor;

        // Static data with service IDs that will match FemaleSpaScreen mapping
        final spaWomenServices = [
          {
            'imagePath': 'assets/spa_massage.webp', 
            'label': 'Full Body Massage',
            'serviceId': 'body_massage',
          },
          {
            'imagePath': 'assets/spa_scrub.webp', 
            'label': 'Body Scrub',
            'serviceId': 'face_treatment',
          },
          {
            'imagePath': 'assets/spa_steam.webp', 
            'label': 'Steam Therapy',
            'serviceId': 'aromatherapy',
          },
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with View All button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spa - Women',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('🟢 Navigating to FemaleSpaScreen - View All');
                    Get.to(
                      () => const FemaleSpaScreen(),
                      transition: Transition.rightToLeft,
                      duration: Duration(milliseconds: 300),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.r * scaleFactor),
                    child: Text(
                      'View all >',
                      style: TextStyle(
                        fontSize: viewAllFontSize,
                        color: const Color(0xFFFF6F00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: topSpacing),

            // Service cards with scrolling navigation
            SizedBox(
              height: cardHeight + (22.h * scaleFactor),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                itemCount: spaWomenServices.length,
                separatorBuilder: (_, __) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final item = spaWomenServices[index];
                  return _SpaWomenCard(
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

class _SpaWomenCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String serviceId;
  final double width;
  final double height;
  final double labelFontSize;
  final double scaleFactor;

  const _SpaWomenCard({
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
          print('🟢 Tapped spa service: $label with serviceId: $serviceId');
          // ✅ FIXED: Pass serviceId as constructor parameter for auto-scrolling
          Get.to(() => FemaleSpaScreen(scrollToServiceId: serviceId));
        } catch (e) {
          print('❌ Spa navigation error: $e');
          Get.snackbar(
            'Error',
            'Unable to open spa service',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
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
                tag: 'spa_women_$serviceId',
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.spa_outlined,
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
                    horizontal: 6.w * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFFFD9BE).withOpacity(0.8),
                        const Color(0xFFFFD9BE),
                      ],
                    ),
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
