import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

//import '../../../controllers/home_controller.dart';
import '../../../services/HomeRepairsScreen.dart';

class AppliancesRepairsSection extends StatelessWidget {
  const AppliancesRepairsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        double titleFontSize = 16.sp * scaleFactor;
        double viewAllFontSize = 14.sp * scaleFactor;
        double cardWidth = 191.11.w * scaleFactor;
        double cardHeight = 260.h * scaleFactor;
        double labelFontSize = 11.sp * scaleFactor;
        double spacing = 12.w * scaleFactor;
        double topSpacing = 8.h * scaleFactor;

        // Static placeholder data with service IDs
        final applianceServices = [
          {'title': 'Chimney', 'image': 'assets/chimney.webp', 'serviceId': 'drain_blockage_fix'},
          {'title': 'Washing Machine', 'image': 'assets/washing_machine.webp', 'serviceId': 'furniture_repair'},
          {'title': 'Water Purifier', 'image': 'assets/water_purifier.webp', 'serviceId': 'touch_up_repainting'},
          {'title': 'Refrigerator', 'image': 'assets/refrigerator.webp', 'serviceId': 'one_wall_painting'},
          {'title': 'Air Cooler', 'image': 'assets/air_cooler.webp', 'serviceId': 'drain_blockage_fix'},
          {'title': 'Television', 'image': 'assets/television.webp', 'serviceId': 'power_socket_repair'},
          {'title': 'AC Services and Repair', 'image': 'assets/ac_repair.webp', 'serviceId': 'furniture_repair'},
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED: Static title row - no Obx needed for static content
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appliances & Repairs',
                  style: TextStyle(
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: titleFontSize,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => HomeRepairsScreen()),
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.r * scaleFactor),
                    child: Text(
                      'View All >',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w700,
                        fontSize: viewAllFontSize,
                        color: const Color(0xFFFA9441),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: topSpacing),

            // ✅ FIXED: Static content - no Obx needed since using static data
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
                itemCount: applianceServices.length,
                separatorBuilder: (_, __) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final appliance = applianceServices[index];
                  return _ApplianceTile(
                    appliance: appliance,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
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

class _ApplianceTile extends StatelessWidget {
  final Map<String, String> appliance;
  final double cardWidth;
  final double cardHeight;
  final double labelFontSize;
  final double scaleFactor;

  const _ApplianceTile({
    required this.appliance,
    required this.cardWidth,
    required this.cardHeight,
    required this.labelFontSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          // ✅ FIXED: Using arguments instead of named parameter
          Get.to(() => HomeRepairsScreen(scrollToServiceId: appliance['serviceId']));

        } catch (e) {
          Get.snackbar(
            'Error',
            'Unable to open repair service',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          border: Border.all(
            color: const Color(0xFFFFD9BE), 
            width: 1.w * scaleFactor
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
                tag: 'appliance_${appliance['serviceId']}',
                child: Image.asset(
                  appliance['image']!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.build_circle,
                        color: const Color(0xFFFF6F00),
                        size: 48.sp * scaleFactor,
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
                  height: 24.h * scaleFactor,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD9BE),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10 * scaleFactor),
                      bottomRight: Radius.circular(10 * scaleFactor),
                    ),
                  ),
                  child: Text(
                    appliance['title']!,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
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
