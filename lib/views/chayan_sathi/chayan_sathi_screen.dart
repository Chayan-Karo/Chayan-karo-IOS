import 'package:chayankaro/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; 
import '../../utils/test_extensions.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../booking/booking_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/chayan_header.dart';
import '../../controllers/saathi_controller.dart';
import '../../models/saathi_models.dart';
import 'chayan_sathi_rating_screen.dart';
import './widgets/bouncy_card.dart';
import '../../widgets/three_dot_loader.dart'; // Custom loader widget
import '../../widgets/app_snackbar.dart';
import 'previouschayansathiscreen.dart';
import '../../controllers/payment_controller.dart';

class ChayanSathiScreen extends StatefulWidget {
  final String categoryId;
  final String serviceId;
  final String locationId;
  final String? addressId;
  final String? initialSlot; // Expected format: "yyyy-MM-dd"
  final int currentBookingDuration; 
  final String? bookingTime; 

  const ChayanSathiScreen({
    super.key,
    required this.categoryId,
    required this.serviceId,
    required this.locationId,
    this.addressId,
    this.initialSlot,
    this.currentBookingDuration = 0,
    this.bookingTime,
  });

  @override
  State<ChayanSathiScreen> createState() => _ChayanSathiScreenState();
}

class _ChayanSathiScreenState extends State<ChayanSathiScreen> {
  late final SaathiController controller;
  final RxSet<String> locallyUnlockedIds = <String>{}.obs;
  late final DateTime bookingDate;

  @override
  void initState() {
    super.initState();

    if (widget.initialSlot != null && widget.initialSlot!.isNotEmpty) {
      try {
        bookingDate = DateFormat('yyyy-MM-dd').parse(widget.initialSlot!);
      } catch (e) {
        debugPrint("⚠️ Date parse error in ChayanSathiScreen: $e");
        bookingDate = DateTime.now(); 
      }
    } else {
      bookingDate = DateTime.now();
    }

    if (Get.isRegistered<SaathiController>(tag: widget.serviceId)) {
      Get.delete<SaathiController>(tag: widget.serviceId);
    }
    controller = Get.put(SaathiController(), tag: widget.serviceId);

    controller.saathiList.clear();
    controller.error.value = '';
    controller.isLoading.value = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProviders(
        categoryId: widget.categoryId,
        serviceId: widget.serviceId,
        locationId: widget.locationId,
        addressId: widget.addressId ?? '',
        bookingDate: bookingDate,
        currentBookingDuration: widget.currentBookingDuration,
        bookingTime: widget.bookingTime, 
      );
    });
  }

  void _showErrorSnackbar(String title, String message) {
    AppSnackbar.showError(message);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.error.value;
      final list = controller.saathiList;
      final lastLockedId = controller.lastLockedProviderId.value;

      bool isProviderUnlocked(SaathiItem p) {
        if (!p.isLocked) return true;
        if (locallyUnlockedIds.contains(p.id)) return true;
        if (p.id == lastLockedId) return true;
        return false;
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final double scaleFactor =
              isTablet ? constraints.maxWidth / 411 : 1.0;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                ChayanHeader(
                  title: 'Chayan Saathi',
                  onBack: () => Navigator.pop(context),
                ),
                if (isLoading && list.isEmpty)
                  Expanded(
                    child: Center(
                          // --- REPLACED CircularProgressIndicator ---
                          child: ThreeDotLoader(
                            size: 14.w * scaleFactor, // Responsive size
                            color: const Color(0xFFE47830),
                          ),
                        )
                  )
                else if ((error.isNotEmpty && list.isEmpty) || list.isEmpty)
                  Expanded(
                      child: _buildEmptySaathiState(context, scaleFactor))
                else
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16.h * scaleFactor,
                        16.h * scaleFactor,
                        16.h * scaleFactor,
                        16.h * scaleFactor,
                      ),
                      itemCount: list.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12 * scaleFactor,
                        mainAxisSpacing: 12 * scaleFactor,
                        // CHANGED: Increased from 0.60 to 0.75 to reduce vertical height
                        childAspectRatio: 0.75, 
                      ),
                      itemBuilder: (context, index) {
                        final saathi = list[index];

                        final isUnlocked = isProviderUnlocked(saathi);
                        
                        final isAvailableTime = controller.isProviderAvailable(saathi);
                        
                        final isClickable = isUnlocked && isAvailableTime;
                        final isLocking = controller.lockingProviderId.value == saathi.id;

                        return Opacity(
                          opacity: isUnlocked ? 1.0 : 0.4,
                          child: BouncyCard(
                            onTap: isClickable
                                ? () async {
                                    if (isLocking) return;

                                    if (saathi.isLocked &&
                                        (locallyUnlockedIds.contains(saathi.id) ||
                                            saathi.id == lastLockedId)) {
                                      if (!mounted) return;
                                      Navigator.pop(
                                          context, _providerPayload(saathi));
                                      return;
                                    }

                                    try {
                                      final res = await controller.lockOnTap(
                                        saathi.id,
                                        bookingDate: bookingDate,
                                      );

                                      if (controller.preferImmediateLock.value) {
                                        if (res != null && res.isSuccess) {
                                          locallyUnlockedIds.add(saathi.id);
                                          if (!mounted) return;
                                          Navigator.pop(context,
                                              _providerPayload(saathi));
                                        } else {
                                          final msg = res?.result ??
                                              controller.error.value;
                                          if (msg.isNotEmpty) {
                                            _showErrorSnackbar(
                                                'Lock Failed', msg);
                                          }
                                        }
                                      } else {
                                        once<LockProviderResponse?>(
                                          controller.lastLockResponse,
                                          (resp) {
                                            if (resp == null) return;
                                            if (resp.isSuccess) {
                                              locallyUnlockedIds.add(saathi.id);
                                              if (!mounted) return;
                                              Navigator.pop(
                                                context,
                                                _providerPayload(saathi),
                                              );
                                            } else {
                                              _showErrorSnackbar(
                                                  'Lock Failed', resp.result);
                                            }
                                          },
                                        );
                                      }
                                    } catch (e) {
                                      _showErrorSnackbar('Error',
                                          e.toString().replaceAll('Exception: ', ''));
                                    }
                                  }
                                : null,
                            child: Stack(
                              children: [
                                _buildSaathiCard(saathi, scaleFactor),
                                if (isLocking)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.black.withOpacity(0.08),
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 22.w * scaleFactor,
                                        height: 22.w * scaleFactor,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ).withId('provider_card_$index'),
                        );
                      },
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: CustomBottomNavBar(
              selectedIndex: controller.selectedIndex.value,
              onItemTapped: (index) =>
                  _onItemTapped(context, controller, index),
            ),
          );
        },
      );
    });
  }

  Map<String, dynamic> _providerPayload(SaathiItem s) {
    return {
      'id': s.id,
      'name': s.name,
      'rating': s.rating ?? 0.0,
      'jobs': s.jobsCompleted ?? 0,
      'image': s.imageUrl ?? '',
      'description': s.description ?? '',
      'addressId': widget.addressId,
      'bookingDate': bookingDate.toIso8601String(),
      
      // Simple return payload
      'availabilityResult': {
        'isAvailable': true, 
        'nextAvailableSlot': null
      }
    };
  }

Widget _buildSaathiCard(SaathiItem saathi, double scaleFactor) {
    final String? img = saathi.imageUrl;
    final bool hasNetImage =
        img != null && img.isNotEmpty && img.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * scaleFactor),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Image
      ClipRRect(
  borderRadius: BorderRadius.vertical(
    top: Radius.circular(15.h * scaleFactor),
  ),
  child: Container(
    height: 115.h * scaleFactor,
    width: double.infinity,
    color: const Color(0xFFFFEEE0), // Your background color for the sides
    child: hasNetImage
        ? Image.network(
            img,
            height: 115.h * scaleFactor,
            width: double.infinity,
            fit: BoxFit.contain, // Shows full face/body
            alignment: Alignment.topCenter, // Keeps head at the top
            // Pass the helper here
            errorBuilder: (_, __, ___) => _buildPlaceholder(scaleFactor),
          )
        : _buildPlaceholder(scaleFactor), // Pass the helper here
  ),
),
          SizedBox(height: 8.h * scaleFactor),

          // 2. Name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Text(
              saathi.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'SFProSemibold',
                fontSize: 14.sp * scaleFactor,
                color: Colors.black,
              ),
            ),
          ),

          SizedBox(height: 4.h * scaleFactor),

          // 3. Jobs Completed
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/tick.svg',
                  width: 14.w * scaleFactor,
                  height: 14.h * scaleFactor,
                ),
                SizedBox(width: 4.w * scaleFactor),
                Expanded(
                  child: Text(
                    '${saathi.jobsCompleted ?? 0} jobs completed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 11.sp * scaleFactor,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h * scaleFactor),

          // 4. Rating Row + RATING SVG ICON
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rating Star and Number
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/star.svg',
                      width: 14.w * scaleFactor,
                      height: 14.h * scaleFactor,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4.w * scaleFactor),
                    Text(
                      (saathi.rating ?? 0.0).toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: 12.sp * scaleFactor,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // --- UPDATED: Rating SVG Button ---
                GestureDetector(
                  onTap: () {
                    // Stop event propagation to the card tap
                    // Navigate to the Rating Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChayanSathiRatingScreen(saathi: saathi),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/review.svg', // Ensure this file exists
                    height: 24.h * scaleFactor, // Adjust size as needed
                    width: 24.w * scaleFactor,
                    fit: BoxFit.contain,
                  ),
                ),
                // --- END UPDATE ---
              ],
            ),
          ),
          
          SizedBox(height: 8.h * scaleFactor),
        ],
      ),
    );
  }
  Widget _buildPlaceholder(double scaleFactor) {
  return Container(
    height: 115.h * scaleFactor,
    width: double.infinity, // Ensures it fills the card width
    color: const Color(0xFFF5F5F5),
    alignment: Alignment.center,
    child: Icon(
      Icons.person,
      size: 40 * scaleFactor,
      color: Colors.grey,
    ),
  );
}

Widget _buildEmptySaathiState(BuildContext context, double scaleFactor) {
  final screenHeight = MediaQuery.of(context).size.height;
  final ProfileController profileController = Get.find<ProfileController>(); // Fetch Controller
  bool isNotified = false;

  // Determine Image based on Gender
  String genderImage = profileController.customer?.gender?.toLowerCase() == 'male' 
      ? "assets/male.png" 
      : "assets/female.png";

  return StatefulBuilder(
    builder: (context, setState) {
      return SingleChildScrollView(
        child: SizedBox(
          height: screenHeight * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- 1. Gender-Based Gamified Illustration ---
              SizedBox(
                width: 280.w * scaleFactor,
                height: 220.h * scaleFactor,
                child: Image.asset(
                  genderImage, // Using PNG instead of SvgPicture.asset
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 24.h * scaleFactor),

              // --- 2. Gamified Title ---
              Text(
                'All our experts are currently busy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp * scaleFactor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SF Pro',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h * scaleFactor),

              // --- 3. Subtext ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    "We'll notify you as soon as one becomes available.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp * scaleFactor,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'SF Pro',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h * scaleFactor),

              // --- 4. Notify Me Card ---
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFEF3EB),
                      radius: 22.r,
                      child: Icon(Icons.notifications_active,
                          color: const Color(0xFFE47830), size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expert Alert',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                          Text(
                            'We will notify you shortly.',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNotified = !isNotified;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE47830),
                          borderRadius:
                              BorderRadius.circular(8 * scaleFactor),
                        ),
                      child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isNotified) ...[
          Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
        ],
        Text(
          isNotified ? 'Notified' : 'Notify Me',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'SF Pro',
          ),
        ),
      ],
    ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h * scaleFactor),

              // --- 5. Navigation Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 155.w * scaleFactor,
                      height: 48.h * scaleFactor,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        border: Border.all(
                          color: const Color(0xFFE47830),
                          width: 1.5.w * scaleFactor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          fontSize: 15.sp * scaleFactor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro',
                          color: const Color(0xFFE47830),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w * scaleFactor),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    child: Container(
                      width: 155.w * scaleFactor,
                      height: 48.h * scaleFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE47830),
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Explore More',
                        style: TextStyle(
                          fontSize: 15.sp * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
  void _onItemTapped(
      BuildContext context, SaathiController controller, int index) {
    controller.onItemTapped(index);
    switch (index) {
       case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => PreviousChayanSathiScreen()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => BookingScreen()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ReferAndEarnScreen()));
        break;
      case 4:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }
}