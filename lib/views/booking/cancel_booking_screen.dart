import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/chayan_header.dart';
import 'BookingCancelledScreen.dart';
import 'showReschedulePopup.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final List<String> reasons = [
    'A reason here for cancellation of booking',
    'A reason here for cancellation of booking, a reason here for cancellation of booking',
    'A reason here for cancellation of booking',
    'A reason here for cancellation of booking, a reason here for cancellation of booking',
  ];

  int? selectedIndex;
  final TextEditingController _issueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

        if (!isTabletDevice) {
          // Phone UI remains unchanged
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChayanHeader(
                    title: 'Cancel Booking',
                    onBack: () => Navigator.pop(context),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20.r),
                      child: Column(
                        children: [
                          // Booking Card
                          Padding(
                            padding: EdgeInsets.all(16.r),
                            child: Container(
                              height: 132.h,
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Color(0xFFF3F3F3), width: 2.w),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.asset(
                                      'assets/cleanup.webp',
                                      width: 100.w,
                                      height: 100.h,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Diamond Facial',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Inter',
                                                color: Color(0xFF161616))),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            _dot(),
                                            SizedBox(width: 8.w),
                                            Text('2 hrs', style: _subTextStyle())
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Row(
                                          children: [
                                            _dot(),
                                            SizedBox(width: 8.w),
                                            Text('Includes dummy info', style: _subTextStyle())
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Reason Title
                          Container(
                            width: double.infinity,
                            color: Color(0xFFF3F3F3),
                            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                            child: Text(
                              'REASON FOR CANCELLATION',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),

                          // Reason options
                          ...List.generate(reasons.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 0.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 18.w,
                                      height: 18.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Color(0xFF757575)),
                                      ),
                                      child: selectedIndex == index
                                          ? Center(
                                              child: Container(
                                                width: 10.w,
                                                height: 10.h,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE47830),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        reasons[index],
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: 'Inter',
                                          color: Color(0xFF161616),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Text Input Area - IMPROVED
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: TextField(
                                controller: _issueController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Describe a problem / comment',
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xFFABABAB),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cancel Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                    child: GestureDetector(
                      onTap: selectedIndex != null ? () => _showBottomPopup(context) : null,
                      child: Container(
                        height: 47.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedIndex != null ? Color(0xFFE47830) : Color(0xFFD7D7D7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel Now',
                          style: TextStyle(
                            color: selectedIndex != null ? Colors.white : Color(0xFF858585),
                            fontSize: 16.sp,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          );
        } else {
          // Tablet UI with scaling
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChayanHeader(
                    title: 'Cancel Booking',
                    onBack: () => Navigator.pop(context),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 20.r * scaleFactor),
                      child: Column(
                        children: [
                          // Booking Card
                          Padding(
                            padding: EdgeInsets.all(16.r * scaleFactor),
                            child: Container(
                              height: 132.h * scaleFactor,
                              padding: EdgeInsets.all(12.r * scaleFactor),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20 * scaleFactor),
                                border: Border.all(color: Color(0xFFF3F3F3), width: 2.w * scaleFactor),
                              ),
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Diamond Facial',
                                            style: TextStyle(
                                                fontSize: 14.sp * scaleFactor,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Inter',
                                                color: Color(0xFF161616))),
                                        SizedBox(height: 8.h * scaleFactor),
                                        Row(
                                          children: [
                                            _dot(scaleFactor),
                                            SizedBox(width: 8.w * scaleFactor),
                                            Text('2 hrs', style: _subTextStyle(scaleFactor))
                                          ],
                                        ),
                                        SizedBox(height: 6.h * scaleFactor),
                                        Row(
                                          children: [
                                            _dot(scaleFactor),
                                            SizedBox(width: 8.w * scaleFactor),
                                            Text('Includes dummy info', style: _subTextStyle(scaleFactor))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Reason Title
                          Container(
                            width: double.infinity,
                            color: Color(0xFFF3F3F3),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.h * scaleFactor, vertical: 12.h * scaleFactor),
                            child: Text(
                              'REASON FOR CANCELLATION',
                              style: TextStyle(
                                fontSize: 12.sp * scaleFactor,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Inter',
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),

                          // Reason options
                          ...List.generate(reasons.length, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    16.w * scaleFactor,
                                    12.w * scaleFactor,
                                    16.w * scaleFactor,
                                    0.w),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 18.w * scaleFactor,
                                      height: 18.h * scaleFactor,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Color(0xFF757575)),
                                      ),
                                      child: selectedIndex == index
                                          ? Center(
                                              child: Container(
                                                width: 10.w * scaleFactor,
                                                height: 10.h * scaleFactor,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE47830),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                    SizedBox(width: 8.w * scaleFactor),
                                    Expanded(
                                      child: Text(
                                        reasons[index],
                                        style: TextStyle(
                                          fontSize: 14.sp * scaleFactor,
                                          fontFamily: 'Inter',
                                          color: Color(0xFF161616),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                          // Text Input Area - IMPROVED WITH SCALING
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.h * scaleFactor, vertical: 24.h * scaleFactor),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF3F3F3),
                                borderRadius: BorderRadius.circular(20 * scaleFactor),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12.w * scaleFactor),
                              child: TextField(
                                controller: _issueController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Describe a problem / comment',
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp * scaleFactor,
                                    color: Color(0xFFABABAB),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Cancel Button
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.h * scaleFactor, vertical: 8.h * scaleFactor),
                    child: GestureDetector(
                      onTap: selectedIndex != null ? () => _showBottomPopup(context, scaleFactor) : null,
                      child: Container(
                        height: 47.h * scaleFactor,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedIndex != null ? Color(0xFFE47830) : Color(0xFFD7D7D7),
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel Now',
                          style: TextStyle(
                            color: selectedIndex != null ? Colors.white : Color(0xFF858585),
                            fontSize: 16.sp * scaleFactor,
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h * scaleFactor),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  TextStyle _subTextStyle([double scaleFactor = 1.0]) {
    return TextStyle(
        fontSize: 14.sp * scaleFactor, fontFamily: 'Inter', color: Color(0xFF757575));
  }

  Widget _dot([double scaleFactor = 1.0]) {
    return Container(
        width: 4.w * scaleFactor,
        height: 4.h * scaleFactor,
        decoration: BoxDecoration(color: Color(0xFF757575), shape: BoxShape.circle));
  }

  void _showBottomPopup(BuildContext context, [double scaleFactor = 1.0]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.h * scaleFactor)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  horizontal: 24.h * scaleFactor, vertical: 24.h * scaleFactor),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.h * scaleFactor)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/icons/sad.svg',
                      width: 40.w * scaleFactor, height: 40.h * scaleFactor),
                  SizedBox(height: 16.h * scaleFactor),
                  Text(
                    'Are you sure about cancelling this booking ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18.sp * scaleFactor,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF161616),
                    ),
                  ),
                  SizedBox(height: 10.h * scaleFactor),
                  Text(
                    'You can always reschedule it',
                    style: TextStyle(
                      fontSize: 12.sp * scaleFactor,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF717171),
                      fontFamily: 'Inter',
                    ),
                  ),
                  SizedBox(height: 24.h * scaleFactor),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => BookingCancelledScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10 * scaleFactor),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cancel anyway',
                            style: TextStyle(
                              fontSize: 14.sp * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w * scaleFactor),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close current popup
                            showReschedulePopup(context); // show reschedule popup
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE47830),
                            padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10 * scaleFactor),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Reschedule',
                            style: TextStyle(
                              fontSize: 14.sp * scaleFactor,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
