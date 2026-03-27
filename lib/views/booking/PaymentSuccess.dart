import './booking_successful_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Extract arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    
    final String paymentMode = (args['method'] ?? 'Online Payment').toString();
    final double totalAmount = (args['amount'] ?? 0.0) * 1.0;
    final String orderId = (args['orderId'] ?? '').toString();
    final String paymentId = (args['paymentId'] ?? '').toString();
    
    // --- NEW: Extract Booking Reference Number ---
    // Matches the key "bookingReferenceNumber" seen in your API logs
    final String bookingRef = (args['bookingReferenceNumber'] ?? '').toString(); 

    // 2. Extract Booking Card Details specifically
    final Map<String, dynamic> bookingCard = 
        (args['bookingCard'] as Map<String, dynamic>?) ?? {};

    final String dateStr = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final String timeStr = DateFormat('hh:mm a').format(DateTime.now());

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

        if (!isTabletDevice) {
          // --- PHONE UI ---
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 60.h),

                  // Orange check circle
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE6EAFF),
                    ),
                    child: Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE47830),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),

                  SizedBox(height: 20.h),
                  Text(
                    'Great',
                    style: TextStyle(
                      color: const Color(0xFFE47830),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Payment Success',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SF Pro Display',
                      color: const Color(0xFF161616),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Payment Info Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // --- NEW: Booking Reference Row (Shown at Top of Card) ---
                        if (bookingRef.isNotEmpty) ...[
                          _infoRow('Booking Ref', bookingRef),
                          SizedBox(height: 16.h),
                        ],

                        //_infoRow('Payment Mode', paymentMode),
                        //SizedBox(height: 16.h),
                        _infoRow('Total Amount', '₹${totalAmount.toStringAsFixed(2)}'),
                        SizedBox(height: 16.h),
                        _infoRow('Pay Date', dateStr),
                        SizedBox(height: 16.h),
                        _infoRow('Pay Time', timeStr),
                        if (orderId.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _infoRow('Order ID', orderId),
                        ],
                        if (paymentId.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _infoRow('Payment ID', paymentId),
                        ],
                        SizedBox(height: 24.h),
                        const Divider(thickness: 2, color: Color(0xFFF3F3F3)),
                        SizedBox(height: 16.h),
                        Text(
                          'Total Pay',
                          style: TextStyle(
                            color: const Color(0xFF757575),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFFE47830),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Done Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 47.h,
                      child: ElevatedButton(
                        onPressed: () {
                          // 3. PASS DATA TO NEXT SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingSuccessfulScreen(
                                bookingId: bookingCard['bookingId']?.toString(),
                                bookingDate: bookingCard['bookingDate']?.toString(),
                                serviceTitle: bookingCard['serviceTitle']?.toString(),
                                // Passing integer minutes if available
                                durationInMinutes: bookingCard['totalDuration'] as int?,
                                imageUrl: bookingCard['imageUrl']?.toString(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE47830),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.32,
                            fontFamily: 'SF Pro Display',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // --- TABLET UI ---
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 60.h * scaleFactor),

                          Container(
                            padding: EdgeInsets.all(10.r * scaleFactor),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE6EAFF),
                            ),
                            child: Container(
                              width: 80.w * scaleFactor,
                              height: 80.h * scaleFactor,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFE47830),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40 * scaleFactor,
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h * scaleFactor),
                          Text(
                            'Great',
                            style: TextStyle(
                              color: const Color(0xFFE47830),
                              fontSize: 16.sp * scaleFactor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 6.h * scaleFactor),
                          Text(
                            'Payment Success',
                            style: TextStyle(
                              fontSize: 20.sp * scaleFactor,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SF Pro Display',
                              color: const Color(0xFF161616),
                            ),
                          ),
                          SizedBox(height: 32.h * scaleFactor),

                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24.w * scaleFactor),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.h * scaleFactor,
                              vertical: 24.h * scaleFactor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16 * scaleFactor),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x14000000),
                                  blurRadius: 10 * scaleFactor,
                                  offset: Offset(0, 4 * scaleFactor),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // --- NEW: Booking Reference Row (Tablet) ---
                                if (bookingRef.isNotEmpty) ...[
                                  _infoRow('Booking Ref', bookingRef, scaleFactor),
                                  SizedBox(height: 16.h * scaleFactor),
                                ],

                                _infoRow('Payment Mode', paymentMode, scaleFactor),
                                SizedBox(height: 16.h * scaleFactor),
                                _infoRow('Total Amount', '₹${totalAmount.toStringAsFixed(2)}', scaleFactor),
                                SizedBox(height: 16.h * scaleFactor),
                                _infoRow('Pay Date', dateStr, scaleFactor),
                                SizedBox(height: 16.h * scaleFactor),
                                _infoRow('Pay Time', timeStr, scaleFactor),
                                if (orderId.isNotEmpty) ...[
                                  SizedBox(height: 16.h * scaleFactor),
                                  _infoRow('Order ID', orderId, scaleFactor),
                                ],
                                if (paymentId.isNotEmpty) ...[
                                  SizedBox(height: 16.h * scaleFactor),
                                  _infoRow('Payment ID', paymentId, scaleFactor),
                                ],
                                SizedBox(height: 24.h * scaleFactor),
                                Divider(
                                  thickness: 2 * scaleFactor,
                                  color: const Color(0xFFF3F3F3),
                                ),
                                SizedBox(height: 16.h * scaleFactor),
                                Text(
                                  'Total Pay',
                                  style: TextStyle(
                                    color: const Color(0xFF757575),
                                    fontSize: 14.sp * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h * scaleFactor),
                                Text(
                                  '₹${totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: const Color(0xFFE47830),
                                    fontSize: 20.sp * scaleFactor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 60.h * scaleFactor),
                        ],
                      ),
                    ),
                  ),

                  // Fixed Done Button at bottom
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.h * scaleFactor,
                      vertical: 24.h * scaleFactor,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 47.h * scaleFactor,
                      child: ElevatedButton(
                        onPressed: () {
                          // 4. PASS DATA TO NEXT SCREEN (Tablet)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingSuccessfulScreen(
                                bookingId: bookingCard['bookingId']?.toString(),
                                bookingDate: bookingCard['bookingDate']?.toString(),
                                serviceTitle: bookingCard['serviceTitle']?.toString(),
                                durationInMinutes: bookingCard['totalDuration'] as int?,
                                imageUrl: bookingCard['imageUrl']?.toString(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE47830),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * scaleFactor),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 16.sp * scaleFactor,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.32,
                            fontFamily: 'SF Pro Display',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _infoRow(String label, String value, [double scaleFactor = 1.0]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF757575),
              fontSize: 14.sp * scaleFactor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 12.w * scaleFactor),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF161616),
              fontSize: 14.sp * scaleFactor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}