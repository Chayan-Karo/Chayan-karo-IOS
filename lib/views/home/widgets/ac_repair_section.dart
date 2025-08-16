import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../services/ACServicesScreen.dart';

class ACRepairSection extends StatelessWidget {
  const ACRepairSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth >= 600;
            double scaleFactor = isTablet
                ? constraints.maxWidth / 411 // base phone width
                : 1.0;

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
                // Section Header
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ACServicesScreen(),
                          ),
                        );
                      },
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

                // Scrollable Cards
                SizedBox(
                  height: containerHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.acRepairItems.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing),
                    itemBuilder: (context, index) {
                      final item = viewModel.acRepairItems[index];
                      return _ACRepairCard(
                        imagePath: item['imagePath']!,
                        title: item['title']!,
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
      },
    );
  }
}

class _ACRepairCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final double width;
  final double height;
  final double labelFontSize;
  final double scaleFactor;

  const _ACRepairCard({
    required this.imagePath,
    required this.title,
    required this.width,
    required this.height,
    required this.labelFontSize,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * scaleFactor),
        border: Border.all(
          color: const Color(0xFFFFD9BE),
          width: 1.w * scaleFactor,
        ),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
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
    );
  }
}