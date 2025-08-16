import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';

class BookingCancelledScreen extends StatelessWidget {
  const BookingCancelledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80.h * scaleFactor),
              SvgPicture.asset(
                'assets/icons/cancel.svg',
                width: 100.w * scaleFactor,
                semanticsLabel: 'Red X icon',
              ),
              SizedBox(height: 16.h * scaleFactor),
              Text(
                'Booking Cancelled !',
                style: TextStyle(
                  color: const Color(0xFFF54343),
                  fontSize: 20.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.h * scaleFactor, vertical: 24.h * scaleFactor),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Dear John Kevin you have successfully cancelled your booking of on date ',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scaleFactor,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: '12 Dec',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp * scaleFactor,
                          color: const Color(0xFF161616),
                        ),
                      ),
                      TextSpan(
                        text: '. We hope to serve you better :)',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                child: Container(
                  height: 132.h * scaleFactor,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFF3F3F3), width: 2.w * scaleFactor),
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                  ),
                  padding: EdgeInsets.all(12.r * scaleFactor),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14 * scaleFactor),
                        child: Image.asset(
                          'assets/cleanup.webp',
                          width: 100.w * scaleFactor,
                          height: 100.h * scaleFactor,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 16.w * scaleFactor),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Diamond Facial',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp * scaleFactor,
                              fontFamily: 'Inter',
                              color: const Color(0xFF161616),
                            ),
                          ),
                          SizedBox(height: 6.h * scaleFactor),
                          Row(
                            children: [
                              _dot(scaleFactor),
                              SizedBox(width: 6.w * scaleFactor),
                              Text(
                                '1 hr',
                                style: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
                                  color: const Color(0xFF757575),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h * scaleFactor),
                          Row(
                            children: [
                              _dot(scaleFactor),
                              SizedBox(width: 6.w * scaleFactor),
                              Text(
                                'Includes dummy info',
                                style: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
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
              SizedBox(height: 16.h * scaleFactor),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                child: SizedBox(
                  width: double.infinity,
                  height: 47.h * scaleFactor,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE47830),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                    ),
                    child: Text(
                      'Go back',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16.sp * scaleFactor,
                        color: Colors.white,
                        letterSpacing: 0.32 * scaleFactor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h * scaleFactor),
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
