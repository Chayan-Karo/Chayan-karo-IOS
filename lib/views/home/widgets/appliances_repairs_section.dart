import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../services/HomeRepairsScreen.dart';

class AppliancesRepairsSection extends StatelessWidget {
  const AppliancesRepairsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            bool isTablet = constraints.maxWidth >= 600;
            double scaleFactor =
                isTablet ? constraints.maxWidth / 411 : 1.0; // Base scaling

            double titleFontSize = 16.sp * scaleFactor;
            double viewAllFontSize = 12.sp * scaleFactor;
            double cardWidth = 191.11.w * scaleFactor;
            double cardHeight = 260.h * scaleFactor;
            double labelFontSize = 11.sp * scaleFactor;
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
                      'Appliances & Repairs',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w600,
                        fontSize: titleFontSize,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeRepairsScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.r * scaleFactor),
                        child: Text(
                          'View All >',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w600,
                            fontSize: viewAllFontSize,
                            color: const Color(0xFFE47830),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: topSpacing),

                // Scrollable Cards
                SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.appliancesRepairItems.length,
                    separatorBuilder: (_, __) => SizedBox(width: spacing),
                    itemBuilder: (context, index) {
                      final appliance = viewModel.appliancesRepairItems[index];
                      return Container(
                        width: cardWidth,
                        height: cardHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                          border: Border.all(
                            color: const Color(0xFFFFD9BE),
                            width: 1.w * scaleFactor,
                          ),
                          image: DecorationImage(
                            image: AssetImage(appliance['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: double.infinity,
                            height: 24.h * scaleFactor,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD9BE),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.h * scaleFactor),
                                bottomRight: Radius.circular(10.h * scaleFactor),
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