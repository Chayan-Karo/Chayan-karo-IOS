// lib/ui/booking/booking_successful_screen.dart
import './booking_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/cart_controller.dart'; 

class BookingSuccessfulScreen extends StatelessWidget {
  final String? bookingId;
  final String? bookingDate;    // yyyy-MM-dd
  final String? serviceTitle;   // e.g., first service name
  final String? durationLabel;  // Fallback string
  final int? durationInMinutes; // NEW: Pass exact minutes (e.g., 90)
  final String? imageUrl;       // optional: service image

  const BookingSuccessfulScreen({
    super.key,
    this.bookingId,
    this.bookingDate,
    this.serviceTitle,
    this.durationLabel,
    this.durationInMinutes, // Add to constructor
    this.imageUrl,
  });

  // Helper method to format minutes into "1 hr 30 m"
  String _formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return '—';
    
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours hr $minutes m';
    } else if (hours > 0) {
      return '$hours hr';
    } else {
      return '$minutes m';
    }
  }

  @override
  Widget build(BuildContext context) {
    // clear cart once after first frame when this screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // safe check to ensure controller exists
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        cartController.clearCart(); 
      }
    });

    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scale = isTablet ? constraints.maxWidth / 411 : 1.0;

      final title = (serviceTitle?.isNotEmpty ?? false) ? serviceTitle! : 'Selected service';
      final dateText = (bookingDate?.isNotEmpty ?? false) ? bookingDate! : '—';
      final idText = (bookingId?.isNotEmpty ?? false) ? bookingId! : '—';

      // LOGIC: Use exact minutes if available, otherwise fallback to label
      String dur;
      if (durationInMinutes != null && durationInMinutes! > 0) {
        dur = _formatDuration(durationInMinutes!);
      } else {
        dur = (durationLabel?.isNotEmpty ?? false) ? durationLabel! : '—';
      }

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w * scale),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h * scale),

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
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (idText != '—') ...[
                        SizedBox(height: 8.h * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w * scale,
                            vertical: 6.h * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFFAF1),
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(color: const Color(0xFFD5F2DA)),
                          ),
                          child: Text(
                            'ID: $idText',
                            style: TextStyle(
                              fontSize: 12.sp * scale,
                              color: const Color(0xFF2F7F48),
                            ),
                          ),
                        ),
                      ],

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h * scale),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Your booking is scheduled for ',
                              ),
                              TextSpan(
                                text: dateText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp * scale,
                                  color: const Color(0xFF161616),
                                ),
                              ),
                              const TextSpan(
                                text:
                                    '. Our service provider will contact you soon.',
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF161616),
                            fontSize: 16.sp * scale,
                          ),
                        ),
                      ),

                      // Booking info card
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF3F3F3),
                            width: 2.w,
                          ),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        padding: EdgeInsets.all(12.r * scale),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14 * scale),
                              child: _buildImage(scale),
                            ),
                            SizedBox(width: 12.w * scale),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp * scale,
                                      color: const Color(0xFF161616),
                                    ),
                                  ),
                                  SizedBox(height: 6.h * scale),
                                  Row(
                                    children: [
                                      _dot(scale),
                                      SizedBox(width: 6.w * scale),
                                      Flexible(
                                        child: Text(
                                          dur,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp * scale,
                                            color: const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h * scale),
                                  Text(
                                    'We will notify you with updates',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp * scale,
                                      color: const Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h * scale),
                    ],
                  ),
                ),
              ),

              // Fixed bottom button area
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w * scale,
                    8.h * scale,
                    16.w * scale,
                    16.h * scale,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 47.h * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(),
                          ),
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
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildImage(double scale) {
    final w = 100.w * scale;
    final h = 100.h * scale;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _assetFallback(w, h),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: w,
            height: h,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFE47830),
            ),
          );
        },
      );
    }
    return _assetFallback(w, h);
  }

  Widget _assetFallback(double w, double h) {
    return Image.asset(
      'assets/facial.webp',
      width: w,
      height: h,
      fit: BoxFit.cover,
    );
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