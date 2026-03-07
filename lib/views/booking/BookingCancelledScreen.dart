// lib/ui/summary/booking_cancelled_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../home/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookingCancelledScreen extends StatelessWidget {
  final String serviceName;
  final int totalDurationMins;
  final String bookingDate;     // yyyy-MM-dd
  final String? customerName;   // optional: e.g., "John Kevin"
  final String? bookingId;      // <--- 1. ADD THIS FIELD
  final bool isRefundable; // <--- 1. ADD THIS FIELD

  const BookingCancelledScreen({
    super.key,
    required this.serviceName,
    required this.totalDurationMins,
    required this.bookingDate,
    this.customerName,
    this.bookingId,             // <--- 2. ADD THIS TO CONSTRUCTOR
    this.isRefundable = false, // <--- 2. ADD TO CONSTRUCTOR WITH DEFAULT
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

     // 1. Success Icon (Green Tick - No Box Decoration)
              SvgPicture.asset(
                'assets/icons/gtick.svg', 
                width: 100.w * scaleFactor,
                height: 100.h * scaleFactor,
              ),

              SizedBox(height: 16.h * scaleFactor),

              // 2. Status Title
              Text(
                'Booking Cancelled Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF27AE60), // Green Color
                  fontSize: 20.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              // --- ADD THIS REFUND BLOCK HERE ---
              if (isRefundable) ...[
                SizedBox(height: 16.h * scaleFactor),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w * scaleFactor),
                  padding: EdgeInsets.all(12.r * scaleFactor),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD), // Light Blue
                    borderRadius: BorderRadius.circular(12 * scaleFactor),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1976D2)),
                      SizedBox(width: 12.w * scaleFactor),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refund Initiated',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1976D2),
                              ),
                            ),
                            Text(
                              'Payment will be sent to your bank within 5 working days.',
                              style: TextStyle(
                                fontSize: 12.sp * scaleFactor,
                                color: const Color(0xFF1976D2),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // ---------------------------------

              // 3. Show Booking ID (Pill Style)
              if (bookingId != null && bookingId!.isNotEmpty) ...[
                SizedBox(height: 12.h * scaleFactor),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w * scaleFactor,
                    vertical: 6.h * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFAF1), // Light Green bg
                    borderRadius: BorderRadius.circular(20 * scaleFactor),
                    border: Border.all(color: const Color(0xFFD5F2DA)),
                  ),
                  child: Text(
                    'ID: $bookingId',
                    style: TextStyle(
                      fontSize: 13.sp * scaleFactor,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2F7F48), // Dark Green text
                    ),
                  ),
                ),
              ],

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
                      // FIX: Wrap Column in Expanded to prevent overflow
                      Expanded(
                        child: Column(
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
                                // Wrap this text in Flexible just in case
                                Flexible(
                                  child: Text(
                                    'Thanks for informing us!',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp * scaleFactor,
                                      color: const Color(0xFF757575),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
