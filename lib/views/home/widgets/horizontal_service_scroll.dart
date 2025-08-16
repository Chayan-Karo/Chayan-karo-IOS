import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';

class HorizontalServiceScroll extends StatelessWidget {
  const HorizontalServiceScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth >= 600;

            // Base scaling factor
            double scaleFactor = isTablet
                ? constraints.maxWidth / 411 // base: common phone width
                : 1.0;

            // Scale all sizes proportionally
            double imageWidth = 117.w * scaleFactor;
            double imageHeight = 116.h * scaleFactor;
            double titleFontSize = 12.sp * scaleFactor;
            double priceFontSize = 12.sp * scaleFactor;
            double oldPriceFontSize = 10.sp * scaleFactor;
            double ratingFontSize = 10.sp * scaleFactor;
            double starSize = 14.h * scaleFactor;

            return SizedBox(
              height: (240.h) * scaleFactor, // proportional list height
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(right: 16.r * scaleFactor),
                itemCount: viewModel.mostUsedServices.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: 12.w * scaleFactor),
                itemBuilder: (context, index) {
                  final service = viewModel.mostUsedServices[index];
                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 0 : 0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Image
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10 * scaleFactor),
                            image: DecorationImage(
                              image: AssetImage(service['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h * scaleFactor),
                        SizedBox(
                          width: imageWidth,
                          child: Text(
                            service['title']!,
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
                              "4.8 (23k)",
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h * scaleFactor),
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
          },
        );
      },
    );
  }
}