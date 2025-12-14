// lib/views/booking/PreviousBookingScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../widgets/chayan_header.dart';

// NEW: import your read model
import '../../models/booking_read_models.dart';

class PreviousBookingScreen extends StatelessWidget {
  final CustomerBooking booking; // inject from list "View details"

  const PreviousBookingScreen({Key? key, required this.booking}) : super(key: key);

  String _humanDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return iso;
    }
  }

  String _humanTime(String hm) {
    try {
      final parts = hm.split(':');
      int h = int.parse(parts[0]);
      final m = parts.length > 1 ? int.parse(parts[1]) : 0;
      final ampm = h >= 12 ? "PM" : "AM";
      h = h % 12;
      if (h == 0) h = 12;
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm";
    } catch (_) {
      return hm;
    }
  }

  String _durationLabel(int mins) {
    if (mins <= 0) return '0 min';
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h > 0 && m > 0) return '${h} hrs ${m} mins';
    if (h > 0) return '${h} hrs';
    return '${m} mins';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        final statusLower = booking.status.toLowerCase();
        final bool isCancelled = statusLower == 'cancelled';
        final bool isCompleted = statusLower == 'completed';

        // Top date (keeps your header line style)
        final topDate = _humanDate(booking.bookingDate);

        // Service list cards (dot-leading, like Upcoming)
        final cards = booking.bookingService.map((svc) {
          final title = svc.categoryName.isNotEmpty ? svc.categoryName : (svc.serviceIName);
          final duration = _durationLabel(booking.totalDuration);
          final details = svc.serviceIName;
          return _bookingCard(
            title: title,
            duration: duration,
            details: details,
            scaleFactor: scaleFactor,
          );
        }).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 24.r * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChayanHeader(
                    title: 'Previous Booking',
                    onBack: () => Navigator.pop(context),
                  ),

                  SizedBox(height: 16.h * scaleFactor),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: Text(
                      topDate, // dynamic date here
                      style: TextStyle(
                        color: const Color(0xFF161616),
                        fontSize: 18.sp * scaleFactor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h * scaleFactor),

                  // Render each service card
                  ...cards.expand((w) => [w, SizedBox(height: 16.h * scaleFactor)]).toList(),

                  // Cancel reason only for cancelled bookings
                  if (isCancelled) _cancelReasonSection(scaleFactor),

                  SizedBox(height: 24.h * scaleFactor),

                  // Billing (80/20 + 18% on platform)
                  _billingSection(
                    scaleFactor,
                    itemTotal: booking.bookingService.fold<num>(0, (sum, s) => sum + (s.price)),
                    itemDiscount: booking.bookingService.fold<num>(0, (sum, s) => sum + (s.price - s.discountPrice)),
                  ),

                  SizedBox(height: 24.h * scaleFactor),

                  // Address + date/time + provider
                  _addressSection(
                    scaleFactor,
                    addressLine: _composeAddress(
                      booking.customerAddress.addressLine1,
                      booking.customerAddress.addressLine2,
                      booking.customerAddress.city,
                      booking.customerAddress.state,
                      booking.customerAddress.postCode,
                    ),
                    dateTimeLabel: "${_humanDate(booking.bookingDate)} - ${_humanTime(booking.bookingTime)}",
                    providerLabel:
                        "${booking.serviceProvider.firstName} ${booking.serviceProvider.lastName}".trim(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _composeAddress(String l1, String? l2, String city, String state, String post) {
    final parts = <String>[];
    if (l1.trim().isNotEmpty) parts.add(l1.trim());
    if ((l2 ?? '').trim().isNotEmpty) parts.add((l2 ?? '').trim());
    if (city.trim().isNotEmpty) parts.add(city.trim());
    if (state.trim().isNotEmpty) parts.add(state.trim());
    if (post.trim().isNotEmpty) parts.add(post.trim());
    return parts.join(', ');
  }

  // Dot-leading service card (matching Upcoming)
  Widget _bookingCard({
    required String title,
    required String duration,
    required String details,
    required double scaleFactor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        padding: EdgeInsets.all(12.r * scaleFactor),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w),
          borderRadius: BorderRadius.circular(14 * scaleFactor),
          color: Colors.white,
        ),
        child: Row(
          children: [
            // Leading dot like Upcoming
            Container(
              width: 8.w * scaleFactor,
              height: 8.h * scaleFactor,
              decoration: const BoxDecoration(color: Color(0xFFE47830), shape: BoxShape.circle),
            ),
            SizedBox(width: 10.w * scaleFactor),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h * scaleFactor),
                  // Details and duration in one line
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          details,
                          softWrap: true,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFF757575)),
                        ),
                      ),
                      SizedBox(width: 8.w * scaleFactor),
                      Text(
                        duration,
                        style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFF757575)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cancel reason section
  Widget _cancelReasonSection(double scaleFactor) {
    final reason = (booking.cancelReason ?? '').trim();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 8.h * scaleFactor),
        padding: EdgeInsets.all(14.r * scaleFactor),
        decoration: ShapeDecoration(
          color: const Color(0xFFFFF7F7),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2.w * scaleFactor, color: const Color(0xFFFFE1E1)),
            borderRadius: BorderRadius.circular(10 * scaleFactor),
          ),
        ),
        child: Text(
          reason.isNotEmpty
              ? "You cancelled this booking because: $reason"
              : "You cancelled this booking.",
          style: TextStyle(
            fontSize: 14.sp * scaleFactor,
            fontFamily: 'Inter',
            color: const Color(0xFFD32F2F),
          ),
        ),
      ),
    );
  }

  Widget _bulletDot(double scaleFactor) {
    return Container(
      width: 4.w * scaleFactor,
      height: 4.h * scaleFactor,
      decoration: const ShapeDecoration(
        color: Color(0xFF757575),
        shape: OvalBorder(),
      ),
    );
  }

  // Updated Billing: 80% per service + 20% platform + 18% GST (on platform)
  Widget _billingSection(
    double scaleFactor, {
    required num itemTotal,
    required num itemDiscount,
  }) {
    // Base to split: post-discount value
    final int bookingBase = (itemTotal - itemDiscount).toInt();
    final int platformFee = (bookingBase * 0.20).round(); // 20%
    final int perService = (bookingBase * 0.80).round(); // 80%
    final int gstOnPlat = (platformFee * 0.18).round(); // 18% of platform
    final int total = perService + platformFee + gstOnPlat;

    final inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2.w * scaleFactor, color: const Color(0xFFF3F3F3)),
            borderRadius: BorderRadius.circular(10 * scaleFactor),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w * scaleFactor, 16.w * scaleFactor, 16.w * scaleFactor, 0),
              child: Row(
                children: [
                  Text(
                    'Billing Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp * scaleFactor,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),

            _billingRow('Per Service Charge', inr.format(perService), scaleFactor: scaleFactor),
            _billingRow('Platform Fee', inr.format(platformFee), scaleFactor: scaleFactor),
            _billingRow('GST on Platform (18%)', inr.format(gstOnPlat),
                color: Colors.black87, scaleFactor: scaleFactor),

            _billingRow('Total', inr.format(total), isBold: true, scaleFactor: scaleFactor),

            Container(
              height: 47.h * scaleFactor,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.h * scaleFactor),
                  bottomRight: Radius.circular(10.h * scaleFactor),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment mode', style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp * scaleFactor)),
                  Text('Online', style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Inter', fontSize: 14.sp * scaleFactor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billingRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
    required double scaleFactor,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w * scaleFactor, 6.w * scaleFactor, 16.w * scaleFactor, 6.w * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp * scaleFactor,
              fontFamily: 'Inter',
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp * scaleFactor,
              fontFamily: 'Inter',
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: color ?? const Color(0xFF161616),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSection(
    double scaleFactor, {
    required String addressLine,
    required String dateTimeLabel,
    required String providerLabel,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        padding: EdgeInsets.all(16.r * scaleFactor),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2.w * scaleFactor, color: const Color(0xFFF3F3F3)),
            borderRadius: BorderRadius.circular(20 * scaleFactor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset('assets/icons/home.svg', width: 20.w * scaleFactor, height: 20.h * scaleFactor, color: Colors.black),
                SizedBox(width: 8.w * scaleFactor),
                Text('Home', style: TextStyle(fontSize: 14.sp * scaleFactor, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
              ],
            ),
            SizedBox(height: 8.h * scaleFactor),
            Text(
              addressLine,
              style: TextStyle(
                fontSize: 12.sp * scaleFactor,
                fontFamily: 'SF Pro Display',
                color: const Color(0xFF757575),
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.h * scaleFactor),
            Row(
              children: [
                SvgPicture.asset('assets/icons/calendar.svg', width: 18.w * scaleFactor, height: 18.h * scaleFactor, color: Colors.black),
                SizedBox(width: 6.w * scaleFactor),
                Text(
                  dateTimeLabel,
                  style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFF757575), fontFamily: 'SF Pro Display'),
                ),
              ],
            ),
            SizedBox(height: 8.h * scaleFactor),
            Row(
              children: [
                SvgPicture.asset('assets/icons/user.svg', width: 20.w * scaleFactor, height: 20.h * scaleFactor, color: Colors.black),
                SizedBox(width: 6.w * scaleFactor),
                Text(
                  providerLabel.isNotEmpty ? providerLabel : 'Provider',
                  style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFF757575), fontFamily: 'SF Pro Display'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
