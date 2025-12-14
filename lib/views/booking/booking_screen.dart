import 'package:chayankaro/views/chayan_sathi/previouschayansathiscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import 'upcoming_booking_screen.dart';
import 'PreviousBookingScreen.dart';
import 'feedback_screen.dart';

// NEW
import '../../controllers/booking_read_controller.dart';
import '../../models/booking_read_models.dart';

class BookingScreen extends StatefulWidget {
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _selectedIndex = 1;
  bool showUpcoming = true;

  // Previous-tab chips
  bool _showCancelled = true;
  bool _showCompleted = true;

  // Read controller for bookings list
  final BookingReadController readCtrl = Get.put(BookingReadController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _fetchUpcoming();
  }

  void _fetchUpcoming() {
    readCtrl.fetchCustomerBookings();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PreviousChayanSathiScreen()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReferAndEarnScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  Widget buildTabBar(double scaleFactor) {
    return Container(
      color: const Color(0xFFFFEDE0),
      padding: EdgeInsets.symmetric(horizontal: 16.h * scaleFactor, vertical: 12.h * scaleFactor),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => showUpcoming = true);
                _fetchUpcoming();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming',
                    style: TextStyle(
                      fontSize: 16.sp * scaleFactor,
                      fontWeight: FontWeight.w500,
                      color: showUpcoming ? const Color(0xFFE47830) : const Color(0xFFA2A2A2),
                    ),
                  ),
                  if (showUpcoming)
                    Container(
                      margin: EdgeInsets.only(top: 4.r * scaleFactor),
                      width: 76.w * scaleFactor,
                      height: 4.h * scaleFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE47830),
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => showUpcoming = false),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 16.sp * scaleFactor,
                      fontWeight: FontWeight.w400,
                      color: !showUpcoming ? const Color(0xFFE47830) : const Color(0xFFA2A2A2),
                    ),
                  ),
                  if (!showUpcoming)
                    Container(
                      margin: EdgeInsets.only(top: 4.r * scaleFactor),
                      width: 72.w * scaleFactor,
                      height: 4.h * scaleFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE47830),
                        borderRadius: BorderRadius.circular(10 * scaleFactor),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PIN boxes (string version)
  Widget buildPinBoxes(String pin, double scaleFactor) {
    return Row(
      children: pin.split('').map((digit) {
        return Container(
          margin: EdgeInsets.only(left: 4.r * scaleFactor),
          width: 20.w * scaleFactor,
          height: 22.h * scaleFactor,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(4 * scaleFactor),
          ),
          child: Text(
            digit,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp * scaleFactor,
              fontWeight: FontWeight.w500,
              fontFamily: 'SF Pro',
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helpers: date and time formatting
  String _humanDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return iso;
    }
  }

  String _displayDate(CustomerBooking b) {
  final dt = b.displayDateTimeLocal;
  if (dt == null) return b.bookingDate.length >= 10 ? b.bookingDate.substring(0,10) : b.bookingDate;
  return DateFormat('dd-MM-yyyy').format(dt);
}

String _displayTime(CustomerBooking b) {
    final dt = b.displayDateTimeLocal;
    
    // 1. If we already have a full DateTime object, use it directly.
    if (dt != null) {
      return DateFormat('hh:mm a').format(dt);
    }

    String t = b.bookingTime; // e.g. "10:30", "15:00", or "11:00"

    // 2. Handle standard "HH:mm" format from your backend
    if (t.contains(':')) {
      try {
        final parts = t.split(':'); // Splits "10:30" into ["10", "30"]
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]); 

        // Convert 24h to 12h AM/PM
        final ap = h >= 12 ? "PM" : "AM";
        final hh12 = (h % 12 == 0) ? 12 : h % 12;
        
        return "${hh12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ap";
      } catch (e) {
        return t; // If data is corrupted, just show raw string
      }
    }

    // 3. Fallback for older "HHmm" format (e.g. "1030") just in case
    if (t.length >= 4) {
      final h = int.tryParse(t.substring(0, 2)) ?? 0;
      final m = int.tryParse(t.substring(2, 4)) ?? 0;
      final ap = h >= 12 ? "PM" : "AM";
      final hh12 = (h % 12 == 0) ? 12 : h % 12;
      return "${hh12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ap";
    }

    return t;
  }


  Widget _pinBoxes(int pin, double scaleFactor) => buildPinBoxes(pin.toString().padLeft(4, '0'), scaleFactor);

  // Dynamic upcoming card from data
  Widget buildUpcomingCardFromBooking(CustomerBooking b, double scaleFactor) {
    final services = b.bookingService;
    final primaryTitle = services.isNotEmpty ? services.first.categoryName : "Service";
    final serviceBullets = services.map((s) => "• ${s.serviceIName}").toList();

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => UpcomingBookingScreen(booking: b)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.h * scaleFactor, vertical: 10.h * scaleFactor),
        padding: EdgeInsets.all(16.r * scaleFactor),
        decoration: BoxDecoration(
          color: const Color(0xFFECEEFF),
          borderRadius: BorderRadius.circular(16 * scaleFactor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    primaryTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.sp * scaleFactor,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: const Color(0xFF161616),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Your PIN',
                      style: TextStyle(
                        fontSize: 10.sp * scaleFactor,
                        color: const Color(0xFF161616),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h * scaleFactor),
                    _pinBoxes(b.bookingPin, scaleFactor),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h * scaleFactor),
            ...serviceBullets.map((t) => Padding(
                  padding: EdgeInsets.only(bottom: 2.h * scaleFactor),
                  child: Text(t, style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFF555555))),
                )),
            SizedBox(height: 12.h * scaleFactor),
            Text('Booking scheduled', style: TextStyle(fontSize: 16.sp * scaleFactor, fontWeight: FontWeight.w600)),
            SizedBox(height: 4.h * scaleFactor),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${_displayDate(b)} / ', style: TextStyle(fontSize: 13.sp * scaleFactor)),
                  TextSpan(text: _displayTime(b), style: TextStyle(fontSize: 10.sp * scaleFactor)),
                ],
              ),
            ),
            SizedBox(height: 4.h * scaleFactor),
            Text(
              'When Your Chayan sathi arrives share your PIN',
              style: TextStyle(fontSize: 8.sp * scaleFactor, color: Colors.black.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // PRESENT previous-card design, with simplified status label
  Widget buildPreviousCardFromBooking(CustomerBooking b, double scaleFactor) {
    final services = b.bookingService;
    final firstService = services.isNotEmpty ? services.first : null;
    
    // --- 1. EXTRACT DATA FOR FEEDBACK ---
    final String serviceName = firstService?.serviceIName ?? 'Service';
  //  final String serviceId = firstService?.serviceId ?? '';
    final String bookingId = b.id ?? '';
    final String spId = b.spId ?? '';

    final dateLabel = _displayDate(b);

    final statusLower = (b.status).toLowerCase();
    final bool isCancelled = statusLower == 'cancelled';
    final bool isCompleted = statusLower == 'completed';

    final String statusText = isCancelled
        ? 'Cancelled'
        : (isCompleted ? 'Completed' : b.status);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h * scaleFactor, vertical: 10.h * scaleFactor),
      padding: EdgeInsets.all(16.r * scaleFactor),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(16 * scaleFactor),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: date and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateLabel, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp * scaleFactor)),
              Text(statusText, style: TextStyle(color: Colors.black54, fontSize: 14.sp * scaleFactor)),
            ],
          ),
          SizedBox(height: 8.h * scaleFactor),

          // Service line
          Row(
            children: [
              Text('• $serviceName', style: TextStyle(color: Colors.black54, fontSize: 12.sp * scaleFactor)),
              Icon(Icons.arrow_drop_down, size: 16 * scaleFactor, color: Colors.black54),
            ],
          ),
          SizedBox(height: 12.h * scaleFactor),

          // Bottom actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCancelled ? Colors.grey : const Color(0xFFE47830),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scaleFactor)),
                  padding: EdgeInsets.symmetric(horizontal: 16.h * scaleFactor, vertical: 8.h * scaleFactor),
                ),
                // --- 2. PASS ARGUMENTS TO FEEDBACK SCREEN ---
                onPressed: isCancelled 
                  ? null 
                  : () {
                    Get.to(
                      () => const FeedbackScreen(),
                      arguments: {
                        'spId': spId,
                        'bookingId': bookingId,
                      //  'serviceId': serviceId,
                        'serviceName': serviceName,
                      },
                    );
                  },
                child: Text('Share Feedback', style: TextStyle(fontSize: 12.sp * scaleFactor, color: Colors.white)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PreviousBookingScreen(booking: b),
                    ),
                  );
                },
                child: Text(
                  'View details',
                  style: TextStyle(fontSize: 12.sp * scaleFactor, color: const Color(0xFFE47830)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPillChipsRow(double scaleFactor) {
  return Padding(
    padding: EdgeInsets.fromLTRB(16.w * scaleFactor, 6.h * scaleFactor, 16.w * scaleFactor, 4.h * scaleFactor), // reduced
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _OutlinedPill(
            label: 'Cancelled',
            selected: _showCancelled,
            onTap: () => setState(() => _showCancelled = !_showCancelled),
            scaleFactor: scaleFactor,
          ),
        ),
        SizedBox(width: 8.w * scaleFactor), // was 10
        Expanded(
          child: _OutlinedPill(
            label: 'Completed',
            selected: _showCompleted,
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            scaleFactor: scaleFactor,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildEmptyState(BuildContext context, double scaleFactor, {bool isPrevious = false}) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 0.75.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 110.w * scaleFactor,
              height: 110.h * scaleFactor,
              child: ClipOval(
                child: SvgPicture.asset(
                  "assets/icons/bookings.svg",
                  fit: BoxFit.cover,
                  width: 110.w * scaleFactor,
                  height: 110.h * scaleFactor,
                ),
              ),
            ),
            SizedBox(height: 20.h * scaleFactor),
            Text(
              isPrevious ? 'No Previous Booking Yet' : 'No Upcoming Booking Yet',
              style: TextStyle(
                fontSize: 20.sp * scaleFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h * scaleFactor),
            Opacity(
              opacity: 0.8,
              child: Text(
                isPrevious
                    ? 'You don’t have any previous bookings yet'
                    : 'You don’t have any upcoming bookings right now',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp * scaleFactor,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30.h * scaleFactor),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              },
              child: Container(
                width: 175.w * scaleFactor,
                height: 45.h * scaleFactor,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                  border: Border.all(
                    color: const Color(0xFFE47830),
                    width: 2.w * scaleFactor,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Explore Services',
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SF Pro',
                    color: const Color(0xFFE47830),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            buildTabBar(scaleFactor),
            Divider(height: 1.h * scaleFactor, color: const Color(0xFFEBEBEB)),

            // Show chips only for Previous tab
            if (!showUpcoming)   _buildPillChipsRow(scaleFactor),

            if (!showUpcoming) Divider(height: 1.h * scaleFactor, color: const Color(0xFFEBEBEB)),

            Expanded(
              child: Obx(() {
                if (readCtrl.isLoading.value && readCtrl.bookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (readCtrl.error.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load bookings: ${readCtrl.error.value}'),
                    ),
                  );
                }

                // Base dataset by tab
                final base = showUpcoming ? readCtrl.upcoming : readCtrl.previous;

                // Apply chip filters for Previous
                final data = showUpcoming
                    ? base
                    : base.where((b) {
                        final s = (b.status).toLowerCase();
                        if (s == 'cancelled' && _showCancelled) return true;
                        if (s == 'completed' && _showCompleted) return true;
                        return false;
                      }).toList();

                if (data.isEmpty) {
                  return _buildEmptyState(context, scaleFactor, isPrevious: !showUpcoming);
                }

                // Sort newest first
                final list = [...data]..sort(
                  (a, b) => DateTime.parse(b.creationTime).compareTo(DateTime.parse(a.creationTime)),
                );

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => showUpcoming
                      ? buildUpcomingCardFromBooking(list[i], scaleFactor)
                      : buildPreviousCardFromBooking(list[i], scaleFactor),
                );
              }),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      );
    });
  }
}
class _OutlinedPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double scaleFactor;

  const _OutlinedPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFE47830);
    final bg = selected ? const Color(0xFFFFF3EA) : Colors.white;
    final border = selected ? orange.withOpacity(0.45) : orange.withOpacity(0.25);
    final textColor = const Color(0xFF6F6F6F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28.h * scaleFactor,                 // was 34
        padding: EdgeInsets.symmetric(              // add minimal padding
          horizontal: 10.w * scaleFactor,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999 * scaleFactor),
          border: Border.all(color: border, width: 1.0 * scaleFactor), // was 1.2
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015), // slightly lighter
              blurRadius: 1.5 * scaleFactor,
              offset: Offset(0, 0.5 * scaleFactor),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 11.sp * scaleFactor,         // was 12
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
