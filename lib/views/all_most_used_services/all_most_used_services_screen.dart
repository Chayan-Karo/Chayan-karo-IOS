import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/common_top_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllMostUsedServicesScreen extends StatelessWidget {
  final List<Map<String, String>> mostUsedServices;

  const AllMostUsedServicesScreen({super.key, required this.mostUsedServices});

  void _onItemTapped(BuildContext context, int index) {
    Navigator.pop(context); // replace with proper navigation
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor =
            isTablet ? constraints.maxWidth / 411 : 1.0; // scale from phone width

        double gridSpacing = 16.w * scaleFactor;
        double gridPadding = 16.w * scaleFactor;
        double titleFontSize = 14.sp * scaleFactor;
        double ratingFontSize = 12.sp * scaleFactor;
        double oldPriceFontSize = 12.sp * scaleFactor;
        double newPriceFontSize = 14.sp * scaleFactor;
        double imageHeight = 110.h * scaleFactor;
        double cardRadius = 12 * scaleFactor;
        double starSize = 14.h * scaleFactor;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                const CommonTopBar(
                  title: 'Most used services',
                  showShareIcon: true,
                ),
                SizedBox(height: 12.h * scaleFactor),

                // Grid of Services
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: gridPadding),
                    child: GridView.builder(
                      itemCount: mostUsedServices.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: gridSpacing,
                        crossAxisSpacing: gridSpacing,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final service = mostUsedServices[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.vertical(top: Radius.circular(cardRadius)),
                                child: Image.asset(
                                  service['image']!,
                                  width: double.infinity,
                                  height: imageHeight,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0.r * scaleFactor),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'SFPro',
                                      ),
                                    ),
                                    SizedBox(height: 4.h * scaleFactor),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/star.svg',
                                          height: starSize,
                                          width: starSize,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 4.w * scaleFactor),
                                        Text(
                                          '4.8 (23k)',
                                          style: TextStyle(
                                            fontSize: ratingFontSize,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h * scaleFactor),
                                    Row(
                                      children: [
                                        Text(
                                          '₹799',
                                          style: TextStyle(
                                            fontSize: oldPriceFontSize,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.black38,
                                          ),
                                        ),
                                        SizedBox(width: 6.w * scaleFactor),
                                        Text(
                                          '₹499',
                                          style: TextStyle(
                                            fontSize: newPriceFontSize,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 2,
            onItemTapped: (index) => _onItemTapped(context, index),
          ),
        );
      },
    );
  }
}
