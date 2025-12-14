// lib/ui/summary/booking_cancelled_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home/home_screen.dart';

class BookingCancelledScreen extends StatelessWidget {
  final String serviceName;
  final int totalDurationMins;
  final String bookingDate;     // yyyy-MM-dd
  final String? customerName;   // optional: e.g., "John Kevin"

  const BookingCancelledScreen({
    super.key,
    required this.serviceName,
    required this.totalDurationMins,
    required this.bookingDate,
    this.customerName,
  });

  String _humanizeDuration(int mins) {
    if (mins <= 0) return '0 min';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String _humanDate(String ymd) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(ymd);
      // Example: Sun, 16 Nov 2025
      return DateFormat('EEE, dd MMM yyyy').format(dt);
    } catch (_) {
      return ymd; // fallback to raw if parse fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

      final readableDate = _humanDate(bookingDate);

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 80.h * scaleFactor),

              // Icon-free status badge
              Container(
                width: 72.w * scaleFactor,
                height: 72.h * scaleFactor,
                decoration: BoxDecoration(
                  color: const Color(0x1AF54343), // light red tint
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF54343), width: 2 * scaleFactor),
                ),
                child: Center(
                  child: Icon(Icons.close_rounded, color: const Color(0xFFF54343), size: 36 * scaleFactor),
                ),
              ),

              SizedBox(height: 16.h * scaleFactor),
              Text(
                'Booking Cancelled!',
                style: TextStyle(
                  color: const Color(0xFFF54343),
                  fontSize: 20.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.h * scaleFactor,
                  vertical: 24.h * scaleFactor,
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            'Dear ${customerName?.trim().isNotEmpty == true ? customerName!.trim() : 'Customer'}, you have successfully cancelled your booking for ',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scaleFactor,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: serviceName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp * scaleFactor,
                          color: const Color(0xFF161616),
                        ),
                      ),
                      TextSpan(
                        text: ' on ',
                        style: TextStyle(
                          color: const Color(0xFF161616),
                          fontSize: 16.sp * scaleFactor,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: readableDate, // human-readable
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
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Asset-free summary card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                child: Container(
                  height: 132.h * scaleFactor,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w * scaleFactor),
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                  ),
                  padding: EdgeInsets.all(12.r * scaleFactor),
                  child: Row(
                    children: [
                      // Orange dot instead of image
                      Container(
                        width: 16.w * scaleFactor,
                        height: 16.h * scaleFactor,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE47830),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 16.w * scaleFactor),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            serviceName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                                _humanizeDuration(totalDurationMins),
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
                                'Thanks for informing us!',
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
