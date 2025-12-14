// lib/ui/summary/cancel_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/chayan_header.dart';
import '../../controllers/booking_controller.dart';
import 'BookingCancelledScreen.dart';
import '../../models/booking_read_models.dart' show CustomerBooking;

class CancelBookingScreen extends StatefulWidget {
  final CustomerBooking? booking;        // optional full booking
  final String? bookingId;               // required if booking is null
  final String? serviceNameFallback;     // used if booking missing
  final int? totalDurationFallback;      // used if booking missing

  const CancelBookingScreen({
    super.key,
    this.booking,
    this.bookingId,
    this.serviceNameFallback,
    this.totalDurationFallback,
  });

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final List<String> reasons = const [
    'Need to change time',
    'Booked by mistake',
    'Schedule no longer needed',
    'Provider not required now',
  ];

  int? selectedIndex;
  final TextEditingController _issueController = TextEditingController();

  late final String bookingId;
  late final String serviceName;
  late final int totalDurationMins;
  late final String bookingDate; // yyyy-MM-dd

  @override
  void initState() {
    super.initState();

    // Strict booking id resolution
    bookingId = (widget.booking?.id?.toString().trim().isNotEmpty ?? false)
        ? widget.booking!.id!.toString()
        : (widget.bookingId ?? '').trim();

    // Derive UI fields safely
    if (widget.booking != null && widget.booking!.bookingService.isNotEmpty) {
      serviceName = widget.booking!.bookingService.first.serviceIName;
      totalDurationMins = widget.booking!.totalDuration;
      bookingDate = (widget.booking!.bookingDate).toString().trim().isNotEmpty
          ? widget.booking!.bookingDate
          : DateTime.now().toIso8601String().split('T').first;
    } else {
      serviceName = widget.serviceNameFallback ?? 'Selected Service';
      totalDurationMins = widget.totalDurationFallback ?? 60;
      bookingDate = DateTime.now().toIso8601String().split('T').first;
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  BookingController _ensureBookingController() {
    if (Get.isRegistered<BookingController>()) return Get.find<BookingController>();
    return Get.put(BookingController());
  }

  TextStyle _subTextStyle([double scaleFactor = 1.0]) {
    return TextStyle(fontSize: 14.sp * scaleFactor, fontFamily: 'Inter', color: const Color(0xFF757575));
  }

  Widget _dot([double scaleFactor = 1.0]) {
    return Container(
      width: 4.w * scaleFactor,
      height: 4.h * scaleFactor,
      decoration: const BoxDecoration(color: Color(0xFF757575), shape: BoxShape.circle),
    );
  }

  String _humanizeDuration(int mins) {
    if (mins <= 0) return '0 min';
    final h = mins ~/ 60, m = mins % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  bool get _canSubmit =>
      bookingId.isNotEmpty && (selectedIndex != null || _issueController.text.trim().isNotEmpty);

  Future<void> _cancelNow(BuildContext context, [double scaleFactor = 1.0]) async {
    if (bookingId.isEmpty) {
      Get.snackbar('Missing booking', 'Booking id not found');
      return;
    }

    final controller = _ensureBookingController();

    // Compose reason (chip > typed > default)
    final chipReason = selectedIndex != null ? reasons[selectedIndex!] : '';
    final typed = _issueController.text.trim();
    final reason = chipReason.isNotEmpty ? chipReason : (typed.isNotEmpty ? typed : 'Change of plan');

    final ok = await controller.cancelBooking(bookingId: bookingId, reason: reason);
    if (!mounted) return;

    if (ok) {
      // Close any popups/overlays if present (defensive)
      Navigator.of(context, rootNavigator: true).popUntil((route) => route is! PopupRoute);

      // Replace with success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingCancelledScreen(
            serviceName: serviceName,
            totalDurationMins: totalDurationMins,
            bookingDate: bookingDate,
            customerName: null,
          ),
        ),
      );
    } else {
      final msg = controller.error.value.isEmpty ? 'Could not cancel booking' : controller.error.value;
      Get.snackbar('Failed', msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTabletDevice = constraints.maxWidth > 600;
      final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

      Widget bookingCard([double s = 1.0]) {
        return Padding(
          padding: EdgeInsets.all(16.r * s),
          child: Container(
            padding: EdgeInsets.all(12.r * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20 * s),
              border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w * s),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 16.w * s,
                  height: 16.h * s,
                  decoration: const BoxDecoration(color: Color(0xFFE47830), shape: BoxShape.circle),
                ),
                SizedBox(width: 12.w * s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: TextStyle(
                          fontSize: 14.sp * s,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                          color: const Color(0xFF161616),
                        ),
                      ),
                      SizedBox(height: 8.h * s),
                      Row(
                        children: [
                          _dot(s),
                          SizedBox(width: 8.w * s),
                          Text(_humanizeDuration(totalDurationMins), style: _subTextStyle(s)),
                        ],
                      ),
                      SizedBox(height: 6.h * s),
                      Row(
                        children: [
                          _dot(s),
                          SizedBox(width: 8.w * s),
                          Text('Includes details as per service', style: _subTextStyle(s)),
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

      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, false); // explicit bool, never null
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChayanHeader(title: 'Cancel Booking', onBack: () => Navigator.pop(context, false)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20.r * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        bookingCard(scaleFactor),

                        // Reason title
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFF3F3F3),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.h * scaleFactor,
                            vertical: 12.h * scaleFactor,
                          ),
                          child: Text(
                            'REASON FOR CANCELLATION',
                            style: TextStyle(
                              fontSize: 12.sp * scaleFactor,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),

                        // Reason options
                        ...List.generate(reasons.length, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedIndex = index),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w * scaleFactor,
                                12.w * scaleFactor,
                                16.w * scaleFactor,
                                0.w,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 18.w * scaleFactor,
                                    height: 18.h * scaleFactor,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF757575)),
                                    ),
                                    child: selectedIndex == index
                                        ? Center(
                                            child: Container(
                                              width: 10.w * scaleFactor,
                                              height: 10.h * scaleFactor,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFE47830),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                  SizedBox(width: 8.w * scaleFactor),
                                  Expanded(
                                    child: Text(
                                      reasons[index],
                                      style: TextStyle(
                                        fontSize: 14.sp * scaleFactor,
                                        fontFamily: 'Inter',
                                        color: const Color(0xFF161616),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Free text
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.h * scaleFactor,
                            vertical: 24.h * scaleFactor,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
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
                                  color: const Color(0xFFABABAB),
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

                // Single-action cancel button (no popup)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.h * scaleFactor,
                    vertical: 8.h * scaleFactor,
                  ),
                  child: GestureDetector(
                    onTap: _canSubmit ? () => _cancelNow(context, scaleFactor) : null,
                    child: Container(
                      height: 47.h * scaleFactor,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _canSubmit ? const Color(0xFFE47830) : const Color(0xFFD7D7D7),
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel Now',
                        style: TextStyle(
                          color: _canSubmit ? Colors.white : const Color(0xFF858585),
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
        ),
      );
    });
  }
}
