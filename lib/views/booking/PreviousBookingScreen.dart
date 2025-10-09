import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreviousBookingScreen extends StatelessWidget {
  const PreviousBookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor =
            isTablet ? constraints.maxWidth / 411 : 1.0;

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
                      '19th Nov, Saturday',
                      style: TextStyle(
                        color: const Color(0xFF161616),
                        fontSize: 18.sp * scaleFactor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h * scaleFactor),
                  _bookingCard(
                    imageAsset: 'assets/ac_services.webp',
                    title: 'AC Service',
                    duration: '1 hrs',
                    details: 'Includes general cleaning',
                    scaleFactor: scaleFactor,
                  ),
                  SizedBox(height: 16.h * scaleFactor),
                  _bookingCard(
                    imageAsset: 'assets/ac_installation.webp',
                    title: 'AC Installation',
                    duration: '30 mins',
                    details: 'Includes lorem',
                    scaleFactor: scaleFactor,
                  ),
                  SizedBox(height: 24.h * scaleFactor),
                  _billingSection(scaleFactor),
                  SizedBox(height: 24.h * scaleFactor),
                  _addressSection(scaleFactor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bookingCard({
    required String imageAsset,
    required String title,
    required String duration,
    required String details,
    required double scaleFactor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        height: 132.h * scaleFactor,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 2.w * scaleFactor, color: const Color(0xFFF3F3F3)),
            borderRadius: BorderRadius.circular(20 * scaleFactor),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 100.w * scaleFactor,
              height: 100.h * scaleFactor,
              margin: EdgeInsets.all(16.r * scaleFactor),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14 * scaleFactor),
                image: DecorationImage(
                  image: AssetImage(imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    top: 20.r * scaleFactor,
                    bottom: 20.r * scaleFactor,
                    right: 12.r * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp * scaleFactor,
                        color: const Color(0xFF161616),
                      ),
                    ),
                    SizedBox(height: 8.h * scaleFactor),
                    Row(
                      children: [
                        _bulletDot(scaleFactor),
                        SizedBox(width: 6.w * scaleFactor),
                        Text(
                          duration,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp * scaleFactor,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h * scaleFactor),
                    Row(
                      children: [
                        _bulletDot(scaleFactor),
                        SizedBox(width: 6.w * scaleFactor),
                        Text(
                          details,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp * scaleFactor,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _billingSection(double scaleFactor) {
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
            _billingRow('Item Total', '₹699', scaleFactor: scaleFactor),
            _billingRow('Item Discount', '-₹50',
                color: const Color(0xFF52B46B), scaleFactor: scaleFactor),
            _billingRow('Service Fee', '₹50', scaleFactor: scaleFactor),
            _billingRow('Grand Total', '₹749', isBold: true, scaleFactor: scaleFactor),
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
                  Text('Payment mode',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp * scaleFactor)),
                  Text('Paytm UPI',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                          fontSize: 14.sp * scaleFactor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billingRow(String label, String value,
      {bool isBold = false, Color? color, required double scaleFactor}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w * scaleFactor, 6.w * scaleFactor, 16.w * scaleFactor, 6.w * scaleFactor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 14.sp * scaleFactor,
                fontFamily: 'Inter',
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              )),
          Text(value,
              style: TextStyle(
                fontSize: 14.sp * scaleFactor,
                fontFamily: 'Inter',
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                color: color ?? const Color(0xFF161616),
              )),
        ],
      ),
    );
  }

  Widget _addressSection(double scaleFactor) {
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
                SvgPicture.asset(
                  'assets/icons/home.svg',
                  width: 20.w * scaleFactor,
                  height: 20.h * scaleFactor,
                  color: Colors.black,
                ),
                SizedBox(width: 8.w * scaleFactor),
                Text(
                  'Home',
                  style: TextStyle(
                      fontSize: 14.sp * scaleFactor,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            SizedBox(height: 8.h * scaleFactor),
            Text(
              'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033, Ph: +91234567890',
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
                SvgPicture.asset(
                  'assets/icons/calendar.svg',
                  width: 18.w * scaleFactor,
                  height: 18.h * scaleFactor,
                  color: Colors.black,
                ),
                SizedBox(width: 6.w * scaleFactor),
                Text(
                  'Sat, Apr 09 - 07:30 PM',
                  style: TextStyle(
                    fontSize: 12.sp * scaleFactor,
                    color: const Color(0xFF757575),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h * scaleFactor),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/user.svg',
                  width: 20.w * scaleFactor,
                  height: 20.h * scaleFactor,
                  color: Colors.black,
                ),
                SizedBox(width: 6.w * scaleFactor),
                Text(
                  'Sumit Gupta, (180+ work), 4.5 rating',
                  style: TextStyle(
                    fontSize: 12.sp * scaleFactor,
                    color: const Color(0xFF757575),
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
