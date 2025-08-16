import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../services/SalonMenServiceScreen.dart';

class SalonMenSection extends StatelessWidget {
  const SalonMenSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth >= 600;
            double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

            double titleFontSize = 16.sp * scaleFactor;
            double viewAllFontSize = 12.sp * scaleFactor;
            double cardWidth = 144.w * scaleFactor;
            double cardHeight = 164.h * scaleFactor;
            double labelHeight = 22.h * scaleFactor;
            double labelFontSize = 10.sp * scaleFactor;
            double spacing = 12.r * scaleFactor;
            double topSpacing = 12.h * scaleFactor;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Salon - Men",
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SalonMenServiceScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.r * scaleFactor),
                        child: Text(
                          "View All >",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: viewAllFontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: topSpacing),

                SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.salonMenItems.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing),
                    itemBuilder: (context, index) {
                      final item = viewModel.salonMenItems[index];
                      return _SalonMenTile(
                        imagePath: item['imagePath']!,
                        label: item['label']!,
                        width: cardWidth,
                        height: cardHeight,
                        labelHeight: labelHeight,
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

class _SalonMenTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final double width;
  final double height;
  final double labelHeight;
  final double labelFontSize;
  final double scaleFactor;

  const _SalonMenTile({
    required this.imagePath,
    required this.label,
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
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}