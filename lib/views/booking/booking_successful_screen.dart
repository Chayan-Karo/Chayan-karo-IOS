import './booking_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookingSuccessfulScreen extends StatelessWidget {
  const BookingSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scale = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80.h * scale),

              // Green tick icon
              SvgPicture.asset(
                'assets/icons/gtick.svg',
                width: 100.w * scale,
                semanticsLabel: 'Green Tick icon',
              ),
              SizedBox(height: 16.h * scale),

              Text(
                'Booking Successful !',
                style: TextStyle(
                  color: const Color(0xFF52B46B),
                  fontSize: 20.sp * scale,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.h * scale, vertical: 24.h * scale),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Dear Harry Styles you have successfully scheduled booking for the upcoming date ',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scale,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: '12 Dec',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp * scale,
                          color: const Color(0xFF161616),
                        ),
                      ),
                      TextSpan(
                        text: '. Our service provider will contact you soon.',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scale,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Booking info card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w * scale),
                child: Container(
                  height: 132.h * scale,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  padding: EdgeInsets.all(12.r * scale),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14 * scale),
                        child: Image.asset(
                          'assets/facial.webp',
                          width: 100.w * scale,
                          height: 100.h * scale,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.w * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Diamond Facial',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp * scale,
                              fontFamily: 'Inter',
                              color: const Color(0xFF161616),
                            ),
                          ),
                          SizedBox(height: 6.h * scale),
                          Row(
                            children: [
                              _dot(scale),
                              SizedBox(width: 6.w * scale),
                              Text(
                                '1 hr',
                                style: TextStyle(
                                  fontSize: 14.sp * scale,
                                  color: const Color(0xFF757575),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h * scale),
                          Row(
                            children: [
                              _dot(scale),
                              SizedBox(width: 6.w * scale),
                              Text(
                                'Includes dummy info',
                                style: TextStyle(
                                  fontSize: 14.sp * scale,
                                  color: const Color(0xFF757575),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h * scale),

              // View Booking button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w * scale),
                child: SizedBox(
                  width: double.infinity,
                  height: 47.h * scale,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => BookingScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE47830),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Text(
                      'View Booking',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16.sp * scale,
                        color: Colors.white,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h * scale),
            ],
          ),
        ),
      );
    });
  }

  Widget _dot(double scale) {
    return Container(
      width: 4.w * scale,
      height: 4.h * scale,
      decoration: const BoxDecoration(
        color: Color(0xFF757575),
        shape: BoxShape.circle,
      ),
    );
  }
}
