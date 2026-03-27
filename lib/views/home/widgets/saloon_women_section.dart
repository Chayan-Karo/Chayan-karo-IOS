import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//import '../../../controllers/home_controller.dart';
import '../../../services/saloonservicescreen.dart';

class SaloonWomenSection extends StatelessWidget {
  const SaloonWomenSection({super.key});

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
        double labelHeight = 22.h * scaleFactor;
        double labelFontSize = 10.sp * scaleFactor;

        // Static data with service IDs that match SalonServiceScreen mapping
        final saloonWomenServices = [
          {
            'title1': 'Bleach & Detan',
            'image1': 'assets/saloon_bleach.webp',
            'serviceId1': 'bleach_detan',
            'title2': 'Facial & Cleanup',
            'image2': 'assets/saloon_facial.webp',
            'serviceId2': 'facial_cleanup',
          },
          {
            'title1': 'Pedicure',
            'image1': 'assets/saloon_pedicure.webp',
            'serviceId1': 'pedicure',
            'title2': 'Threading',
            'image2': 'assets/saloon_threading.webp',
            'serviceId2': 'threading',
          },
          {
            'title1': 'Waxing',
            'image1': 'assets/saloon_waxing.webp',
            'serviceId1': 'waxing',
            'title2': 'Manicure',
            'image2': 'assets/saloon_manicure.webp',
            'serviceId2': 'manicure',
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
                  'Saloon - Women',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('🟢 Navigating to SalonServiceScreen - View All');
                    Get.to(() => const SalonServiceScreen());
                  },
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

            // Service cards with scrolling navigation
            SizedBox(
              height: (cardHeight * 2) + (8.h * scaleFactor),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                itemCount: saloonWomenServices.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w * scaleFactor),
                itemBuilder: (context, index) {
                  final item = saloonWomenServices[index];
                  return Column(
                    children: [
                      _ServiceCard(
                        title: item['title1']!,
                        imageAsset: item['image1']!,
                        serviceId: item['serviceId1']!,
                        width: cardWidth,
                        height: cardHeight,
                        labelHeight: labelHeight,
                        labelFontSize: labelFontSize,
                        scaleFactor: scaleFactor,
                      ),
                      SizedBox(height: 8.h * scaleFactor),
                      _ServiceCard(
                        title: item['title2']!,
                        imageAsset: item['image2']!,
                        serviceId: item['serviceId2']!,
                        width: cardWidth,
                        height: cardHeight,
                        labelHeight: labelHeight,
                        labelFontSize: labelFontSize,
                        scaleFactor: scaleFactor,
                      ),
                    ],
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

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final String serviceId;
  final double width;
  final double height;
  final double labelHeight;
  final double labelFontSize;
  final double scaleFactor;

  const _ServiceCard({
    required this.title,
    required this.imageAsset,
    required this.serviceId,
    required this.width,
    required this.height,
    required this.labelHeight,
    required this.labelFontSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          print('🟢 Tapped service: $title with serviceId: $serviceId');
          // Navigate with scrollToServiceId parameter for auto-scrolling
          Get.to(() => SalonServiceScreen(scrollToServiceId: serviceId));
        } catch (e) {
          print('❌ Navigation error: $e');
          Get.snackbar(
            'Error',
            'Unable to open service details',
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
                tag: 'salon_service_$serviceId',
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.face_retouching_natural,
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
                  height: labelHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9BE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10 * scaleFactor),
                      bottomRight: Radius.circular(10 * scaleFactor),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                    child: Text(
                      title,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
