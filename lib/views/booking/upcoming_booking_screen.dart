import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../../widgets/chayan_header.dart';
import 'cancel_booking_screen.dart';
import 'showReschedulePopup.dart';
import 'Helpscreen.dart';
import 'EmergencyScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpcomingBookingScreen extends StatelessWidget {
  const UpcomingBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0xFFFFEEE0),
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Header
                  ChayanHeader(title: 'Upcoming Booking', onBackTap: () {}),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h * scaleFactor),

                          // Date + Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('22nd',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18.sp * scaleFactor)),
                                  Text('Nov, Tuesday',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18.sp * scaleFactor)),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => HelpScreen()));
                                    },
                                    child: _actionButton('Help',
                                        'assets/icons/help.svg', const Color(0xFFE47830),
                                        scaleFactor: scaleFactor),
                                  ),
                                  SizedBox(width: 8.w * scaleFactor),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => EmergencyScreen()));
                                    },
                                    child: _actionButton(
                                        'Emergency',
                                        'assets/icons/emergency.svg',
                                        const Color(0xFFFF3300),
                                        scaleFactor: scaleFactor),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 20.h * scaleFactor),

                          // Service Cards
                          _bookingCard('assets/facial.webp', 'Diamond Facial', '2 hrs',
                              'Includes lorem ipsum', scaleFactor),
                          SizedBox(height: 16.h * scaleFactor),
                          _bookingCard(
                              'assets/cleanup.webp', 'Cleanup', '30 mins', 'Includes lorem', scaleFactor),

                          SizedBox(height: 20.h * scaleFactor),

                          // Billing
                          Container(
                            padding: EdgeInsets.all(16.r * scaleFactor),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12 * scaleFactor),
                              border: Border.all(
                                  color: const Color(0xFFF3F3F3), width: 2.w),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Billing Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp * scaleFactor)),
                                SizedBox(height: 16.h * scaleFactor),
                                _billingRow('Item Total', '₹699', scaleFactor: scaleFactor),
                                _billingRow('Item Discount', '-₹50',
                                    valueColor: const Color(0xFF52B46B),
                                    scaleFactor: scaleFactor),
                                _billingRow('Service Fee', '₹50', scaleFactor: scaleFactor),
                                Divider(height: 30.h * scaleFactor),
                                _billingRow('Grand Total', '₹749',
                                    isBold: true, scaleFactor: scaleFactor),
                                SizedBox(height: 16.h * scaleFactor),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.h * scaleFactor,
                                      horizontal: 16.h * scaleFactor),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F3F3),
                                    borderRadius:
                                        BorderRadius.circular(10 * scaleFactor),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Payment mode',
                                          style: TextStyle(
                                              fontSize: 14.sp * scaleFactor)),
                                      Text('Paytm UPI',
                                          style: TextStyle(
                                              fontSize: 14.sp * scaleFactor,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h * scaleFactor),

                          // Address Section
                          Container(
                            padding: EdgeInsets.all(16.r * scaleFactor),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12 * scaleFactor),
                              border: Border.all(
                                  color: const Color(0xFFF3F3F3), width: 2.w),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow('assets/icons/home.svg',
                                    'Home', scaleFactor),
                                SizedBox(height: 4.h * scaleFactor),
                                Padding(
                                  padding: EdgeInsets.only(left: 32.r * scaleFactor),
                                  child: Text(
                                    'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033, Ph: +91234567890',
                                    style: TextStyle(
                                        fontSize: 12.sp * scaleFactor,
                                        color: const Color(0xFF757575),
                                        height: 1.5.h),
                                  ),
                                ),
                                SizedBox(height: 12.h * scaleFactor),
                                _infoRow('assets/icons/calendar.svg',
                                    'Sat, Apr 09 - 07:30 PM', scaleFactor),
                                SizedBox(height: 12.h * scaleFactor),
                                _infoRow('assets/icons/user.svg',
                                    'Sumit Gupta, (180+ work), 4.5 rating', scaleFactor),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h * scaleFactor),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Bottom Buttons - THIS IS THE KEY FIX
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          16.w * scaleFactor, 20.w * scaleFactor, 16.w * scaleFactor, 20.w * scaleFactor),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => CancelBookingScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.h * scaleFactor),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scaleFactor),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp * scaleFactor, // FIXED: Added scaled font size
                                  fontWeight: FontWeight.w500, // Added font weight for consistency
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w * scaleFactor),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => showReschedulePopup(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE47830),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.h * scaleFactor),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scaleFactor),
                                ),
                              ),
                              child: Text(
                                'Reschedule',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp * scaleFactor, // FIXED: Added scaled font size
                                  fontWeight: FontWeight.w500, // Added font weight for consistency
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(String label, String iconPath, Color color,
      {required double scaleFactor}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w * scaleFactor),
      height: 28.h * scaleFactor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5 * scaleFactor),
      ),
      child: Row(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: SvgPicture.asset(iconPath,
                width: 16.w * scaleFactor, height: 16.h * scaleFactor),
          ),
          SizedBox(width: 4.w * scaleFactor),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp * scaleFactor,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _bookingCard(
      String imagePath, String title, String duration, String subtitle, double scaleFactor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w),
        borderRadius: BorderRadius.circular(20 * scaleFactor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14 * scaleFactor),
            child: Image.asset(imagePath,
                width: 100.w * scaleFactor,
                height: 100.h * scaleFactor,
                fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w * scaleFactor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp * scaleFactor)),
                  SizedBox(height: 8.h * scaleFactor),
                  _detailRow(duration, scaleFactor),
                  SizedBox(height: 4.h * scaleFactor),
                  if (subtitle.isNotEmpty) _detailRow(subtitle, scaleFactor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billingRow(String label, String value,
      {Color valueColor = Colors.black,
      bool isBold = false,
      required double scaleFactor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14.sp * scaleFactor,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: 14.sp * scaleFactor,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  color: valueColor)),
        ],
      ),
    );
  }

  Widget _infoRow(String iconPath, String text, double scaleFactor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          child:
              SvgPicture.asset(iconPath, width: 20.w * scaleFactor, height: 20.h * scaleFactor),
        ),
        SizedBox(width: 8.w * scaleFactor),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.sp * scaleFactor, color: const Color(0xFF757575)))),
      ],
    );
  }

  Widget _detailRow(String text, double scaleFactor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _dot(scaleFactor),
        SizedBox(width: 6.w * scaleFactor),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp * scaleFactor, color: const Color(0xFF757575)),
          ),
        ),
      ],
    );
  }

  Widget _dot(double scaleFactor) {
    return Container(
      width: 4.w * scaleFactor,
      height: 4.h * scaleFactor,
      decoration: const BoxDecoration(
        color: Color(0xFF757575),
        shape: BoxShape.circle,
      ),
    );
  }
}
