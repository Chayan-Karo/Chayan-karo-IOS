import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../services/MaleSpaScreen.dart';
import '../../../viewmodels/home_viewmodel.dart';

class MaleSpaSection extends StatelessWidget {
  const MaleSpaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final homeVM = Provider.of<HomeViewModel>(context);

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
        double labelFontSize = 10.sp * scaleFactor;
        double spacing = 12.w * scaleFactor;
        double topSpacing = 12.h * scaleFactor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spa - Men',
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
                      MaterialPageRoute(builder: (_) =>  MaleSpaScreen()),
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

            // Horizontal Scroll Cards
            SizedBox(
              height: cardHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: homeVM.maleSpaItems.length,
                separatorBuilder: (_, __) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final item = homeVM.maleSpaItems[index];
                  return _MaleSpaCard(
                    imagePath: item['imagePath']!,
                    label: item['label']!,
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

class _MaleSpaCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final double width;
  final double height;
  final double labelFontSize;
  final double scaleFactor;

  const _MaleSpaCard({
    required this.imagePath,
    required this.label,
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
        border: Border.all(color: const Color(0xFFFFD9BE), width: 1.w * scaleFactor),
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
    );
  }
}
