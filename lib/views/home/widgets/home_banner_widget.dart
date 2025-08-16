import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';

class HomeBannerWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const HomeBannerWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        final bannerData = viewModel.bannerData;
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Container(
            height: 120.h * scaleFactor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scaleFactor),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8F39), Color(0xFFFF6F00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerData['title']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp * scaleFactor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h * scaleFactor),
                        Row(
                          children: [
                            Text(
                              bannerData['subtitle']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp * scaleFactor,
                              ),
                            ),
                            SizedBox(width: 6.w * scaleFactor),
                            Icon(Icons.arrow_forward, size: 16 * scaleFactor, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12.r * scaleFactor),
                    bottomRight: Radius.circular(12.r * scaleFactor),
                  ),
                  child: Image.asset(
                    bannerData['image']!,
                    height: 120.h * scaleFactor,
                    width: 100.w * scaleFactor,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}