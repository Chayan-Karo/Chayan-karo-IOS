import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginRequiredWidget extends StatelessWidget {
  final String title;
  final String message;
  final String iconPath;
  final double scaleFactor;

  const LoginRequiredWidget({
    super.key,
    required this.title,
    required this.message,
    this.iconPath = "assets/icons/logo.svg", // Default icon
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: screenHeight * 0.75.h, // Matching your empty state height logic
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- Icon Section (Replicated from _buildEmptyState) ---
            SizedBox(
              width: 110.w * scaleFactor,
              height: 110.h * scaleFactor,
              child: ClipOval(
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.cover,
                  // Fallback if specific icon fails
                  placeholderBuilder: (context) => Icon(
                    Icons.account_circle_outlined,
                    size: 80.sp,
                    color: const Color(0xFFE47830).withOpacity(0.5),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h * scaleFactor),

            // --- Title Section ---
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 5.h * scaleFactor),

            // --- Message Section ---
            Opacity(
              opacity: 0.8,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w * scaleFactor),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp * scaleFactor,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro',
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h * scaleFactor),

            // --- Primary Action Button ---
            GestureDetector(
              onTap: () => Get.toNamed('/login'),
              child: Container(
                width: 175.w * scaleFactor,
                height: 45.h * scaleFactor,
                decoration: BoxDecoration(
                  color: const Color(0xFFE47830), // Filled version for Login
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE47830).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log In Now',
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SF Pro',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}