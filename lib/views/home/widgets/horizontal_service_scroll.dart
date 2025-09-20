import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';

class HorizontalServiceScroll extends StatelessWidget {
  const HorizontalServiceScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        // Scale all sizes proportionally
        double imageWidth = 117.w * scaleFactor;
        double imageHeight = 116.h * scaleFactor;
        double titleFontSize = 12.sp * scaleFactor;
        double priceFontSize = 12.sp * scaleFactor;
        double oldPriceFontSize = 10.sp * scaleFactor;
        double ratingFontSize = 10.sp * scaleFactor;
        double starSize = 14.h * scaleFactor;

        return Obx(() {
          final homeController = Get.find<HomeController>();
          final services = homeController.mostUsedServices;

          // Handle loading state
          if (homeController.isLoading && services.isEmpty) {
            return SizedBox(
              height: 200.h * scaleFactor,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF6F00),
                ),
              ),
            );
          }

          // Handle empty state
          if (services.isEmpty) {
            return SizedBox(
              height: 200.h * scaleFactor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cleaning_services_outlined,
                      size: 48 * scaleFactor,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8.h * scaleFactor),
                    Text(
                      'No services available',
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

          // ✅ FIXED: Use a more precise height calculation to minimize padding
          double contentHeight = imageHeight + 
                                8.h * scaleFactor + // after image
                                (titleFontSize * 1.33 * 2) + // title space (2 lines)
                                4.h * scaleFactor + // after title
                                (ratingFontSize * 1.2) + // rating height
                                4.h * scaleFactor + // after rating
                                (priceFontSize * 1.2) + // price height
                                5.h * scaleFactor; // buffer to prevent overflow

          return Container(
            height: contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // ✅ FIXED: Zero padding to eliminate any extra space
              padding: EdgeInsets.zero,
              itemCount: services.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w * scaleFactor),
              itemBuilder: (context, index) {
                final service = services[index];
                
                return SizedBox(
                  width: imageWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image
                      Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
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
                          child: Image.asset(
                            service.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.cleaning_services,
                                  color: const Color(0xFFFF6F00),
                                  size: 32.sp * scaleFactor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h * scaleFactor),
                      
                      // Service Title
                      SizedBox(
                        width: imageWidth,
                        child: Text(
                          service.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                            color: Colors.black,
                            height: 1.33,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4.h * scaleFactor),
                      
                      // Rating Row
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/star.svg',
                            height: starSize,
                            width: starSize,
                            colorFilter: const ColorFilter.mode(
                              Colors.amber,
                              BlendMode.srcIn,
                            ),
                            placeholderBuilder: (_) => Icon(
                              Icons.star,
                              size: starSize,
                              color: Colors.amber,
                            ),
                          ),
                          SizedBox(width: 4.w * scaleFactor),
                          Expanded(
                            child: Text(
                              "4.8 (23k)",
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF757575),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h * scaleFactor),
                      
                      // Price Row
                      Row(
                        children: [
                          Text(
                            "₹499",
                            style: TextStyle(
                              fontSize: priceFontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFA9441),
                            ),
                          ),
                          SizedBox(width: 6.w * scaleFactor),
                          Text(
                            "₹599",
                            style: TextStyle(
                              fontSize: oldPriceFontSize,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFFB0B0B0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }
}
