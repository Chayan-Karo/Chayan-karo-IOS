import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../all_most_used_services/all_most_used_services_screen.dart';
import './horizontal_service_scroll.dart';
import './appliances_repairs_section.dart';
import './salon_men_section.dart';
import './ac_repair_section.dart';
import './male_spa_section.dart';
import './spa_women_section.dart';
import './saloon_women_section.dart';

class MostUsedServicesWidget extends StatelessWidget {
  final double scaleFactor;

  const MostUsedServicesWidget({
    Key? key,
    required this.scaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0 * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ FIXED: Static title with reactive "View All" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most used services',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              Obx(() {
                final homeController = Get.find<HomeController>();
                return GestureDetector(
                  onTap: () {
                    try {
                      if (homeController.mostUsedServices.isNotEmpty) {
                        Get.to(() => AllMostUsedServicesScreen(
                          mostUsedServices: homeController.mostUsedServices.toList(),
                        ));
                      } else {
                        Get.snackbar(
                          'No Services',
                          'No services available at the moment',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFFF6F00),
                          colorText: Colors.white,
                          duration: Duration(seconds: 2),
                        );
                      }
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Something went wrong',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 16 * scaleFactor),
                    child: Text(
                      'View all >',
                      style: TextStyle(
                        color: homeController.mostUsedServices.isNotEmpty 
                            ? Colors.orange 
                            : Colors.orange.withOpacity(0.5),
                        fontSize: 14.sp * scaleFactor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          
          SizedBox(height: 12.h * scaleFactor),

          // ✅ FIXED: Let HorizontalServiceScroll handle its own reactivity
          // No Obx wrapper here since HorizontalServiceScroll has its own Obx inside
          SizedBox(
            height: 240.h * scaleFactor,
            child: const HorizontalServiceScroll(),
          ),

          SizedBox(height: 24.h * scaleFactor),

          // ✅ FIXED: All service sections - these should now appear
          const SaloonWomenSection(),
          SizedBox(height: 24.h * scaleFactor),
          
          const SpaWomenSection(),
          SizedBox(height: 24.h * scaleFactor),
          
          const MaleSpaSection(),
          SizedBox(height: 24.h * scaleFactor),
          
          const SalonMenSection(),
          SizedBox(height: 24.h * scaleFactor),
          
          const ACRepairSection(),
          SizedBox(height: 24.h * scaleFactor),
          
          const AppliancesRepairsSection(),
          SizedBox(height: 24.h * scaleFactor), // Extra bottom padding
        ],
      ),
    );
  }
}
