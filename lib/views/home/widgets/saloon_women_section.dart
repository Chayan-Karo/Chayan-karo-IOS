import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../services/saloonservicescreen.dart';

class SaloonWomenSection extends StatelessWidget {
  const SaloonWomenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth >= 600;
            double scaleFactor = isTablet
                ? constraints.maxWidth / 411 // scale from common phone width
                : 1.0;

            double titleFontSize = 16.sp * scaleFactor;
            double viewAllFontSize = 13.sp * scaleFactor;
            double cardWidth = 144.w * scaleFactor;
            double cardHeight = 164.h * scaleFactor;
            double labelHeight = 22.h * scaleFactor;
            double labelFontSize = 10.sp * scaleFactor;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SalonServiceScreen(),
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

                SizedBox(height: 8.h * scaleFactor),

                // Cards scroll
                SizedBox(
                  height: (cardHeight * 2) + (8.h * scaleFactor), // two stacked cards
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: viewModel.saloonWomenItems.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w * scaleFactor),
                    itemBuilder: (context, index) {
                      final item = viewModel.saloonWomenItems[index];
                      return Column(
                        children: [
                          _ServiceCard(
                            title: item['title1']!,
                            imageAsset: item['image1']!,
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
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final double width;
  final double height;
  final double labelHeight;
  final double labelFontSize;
  final double scaleFactor;

  const _ServiceCard({
    required this.title,
    required this.imageAsset,
    required this.width,
    required this.height,
    required this.labelHeight,
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
        border: Border.all(color: const Color(0xFFFFD9BE), width: 1.w * scaleFactor),
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: labelHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD9BE),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.h * scaleFactor),
              bottomRight: Radius.circular(10.h * scaleFactor),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}