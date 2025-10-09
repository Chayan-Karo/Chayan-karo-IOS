import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header stays at top
            ChayanHeader(title: 'Emergency', onBack: () => Navigator.pop(context)),

            // Main content below header
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 20.h * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: "Need assistance?"
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                      child: Text(
                        'Need assistance?',
                        style: TextStyle(
                          fontSize: 20.sp * scaleFactor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SF Pro',
                          letterSpacing: 0.2 * scaleFactor,
                          color: const Color(0xFF161616),
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h * scaleFactor),

                    // Call for support button
                    Padding(
                      padding: EdgeInsets.only(left: 16.r * scaleFactor),
                      child: Container(
                        width: 148.w * scaleFactor,
                        height: 33.h * scaleFactor,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(5 * scaleFactor),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 6.w * scaleFactor),
                            SvgPicture.asset(
                              'assets/icons/help.svg',
                              height: 20.h * scaleFactor,
                              width: 20.w * scaleFactor,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10.w * scaleFactor),
                            Text(
                              'Call For Support',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SF Pro',
                                letterSpacing: 0.14 * scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 25.h * scaleFactor),

                    Container(height: 6.h * scaleFactor, color: const Color(0x7FD9D9D9)),

                    Padding(
                      padding: EdgeInsets.only(left: 16.r * scaleFactor, top: 20.r * scaleFactor),
                      child: Text(
                        'Local emergency contacts',
                        style: TextStyle(
                          fontSize: 18.sp * scaleFactor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro',
                          color: const Color(0xFF161616),
                          letterSpacing: 0.18 * scaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h * scaleFactor),

                    _buildEmergencyRow(
                      iconAsset: 'assets/icons/emergency.svg',
                      label: 'All emergencies',
                      number: 'Call 112',
                      scale: scaleFactor,
                    ),
                    _buildDivider(scaleFactor),
                    _buildEmergencyRow(
                      iconAsset: 'assets/icons/police.svg',
                      label: 'Police',
                      number: 'Call 100',
                      scale: scaleFactor,
                    ),
                    _buildDivider(scaleFactor),
                    _buildEmergencyRow(
                      iconAsset: 'assets/icons/med.svg',
                      label: 'Medical',
                      number: 'Call 101',
                      scale: scaleFactor,
                    ),
                    _buildDivider(scaleFactor),
                    _buildEmergencyRow(
                      iconAsset: 'assets/icons/fire.svg',
                      label: 'Fire',
                      number: 'Call 102',
                      scale: scaleFactor,
                    ),
                    _buildDivider(scaleFactor),
                    SizedBox(height: 40.h * scaleFactor),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmergencyRow({
    required String iconAsset,
    required String label,
    required String number,
    required double scale,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.h * scale, vertical: 7.h * scale),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 25.w * scale,
            height: 25.h * scale,
            color: Colors.black,
          ),
          SizedBox(width: 14.w * scale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp * scale,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
                letterSpacing: 0.13 * scale,
              ),
            ),
          ),
          Text(
            number,
            style: TextStyle(
              fontSize: 13.sp * scale,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
              letterSpacing: 0.13 * scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(double scale) {
    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w * scale),
        child: Container(
          height: 1.h * scale,
          color: const Color(0xFFD9D9D9),
        ),
      ),
    );
  }
}
