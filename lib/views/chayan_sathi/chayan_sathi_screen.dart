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
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      shouldIconPulse: true,
      duration: const Duration(seconds: 3),
    );
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
                      child: SizedBox(
                        width: 28.w * scaleFactor,
                        height: 28.w * scaleFactor,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
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
                        90.h * scaleFactor,
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
                          child: InkWell(
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
        mainAxisSize: MainAxisSize.min, // Ensure column only takes needed space
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.h * scaleFactor),
            ),
            child: hasNetImage
                ? Image.network(
                    img!,
                    height: 125.h * scaleFactor,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 125.h * scaleFactor,
                      color: const Color(0xFFF5F5F5),
                      alignment: Alignment.center,
                      child: Icon(Icons.person,
                          size: 40 * scaleFactor, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 125.h * scaleFactor,
                    color: const Color(0xFFF5F5F5),
                    alignment: Alignment.center,
                    child: Icon(Icons.person,
                        size: 40 * scaleFactor, color: Colors.grey),
                  ),
          ),
          SizedBox(height: 8.h * scaleFactor),
          
          // Name
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
          
          SizedBox(height: 6.h * scaleFactor),
          
          // Jobs
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
                Text(
                  '${saathi.jobsCompleted ?? 0} jobs completed',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.sp * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 4.h * scaleFactor),
          
          // Rating
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/star.svg',
                  width: 14.w * scaleFactor,
                  height: 14.h * scaleFactor,
                  color: Colors.black,
                ),
                SizedBox(width: 4.w * scaleFactor),
                Text(
                  '${(saathi.rating ?? 0.0).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.sp * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Added a minimal padding at the bottom instead of large sized box
          SizedBox(height: 10.h * scaleFactor),
        ],
      ),
    );
  }

  Widget _buildEmptySaathiState(BuildContext context, double scaleFactor) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenHeight * 0.75.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110.w * scaleFactor,
              height: 110.h * scaleFactor,
              child: ClipOval(
                child: SvgPicture.asset(
                  "assets/icons/chayansathi.svg",
                  fit: BoxFit.cover,
                  width: 110.w * scaleFactor,
                  height: 110.h * scaleFactor,
                ),
              ),
            ),
            SizedBox(height: 20.h * scaleFactor),
            Text(
              'No Service Providers Found',
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
                'No service provider is currently available in your area.',
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
            ).withId('chayan_sathi_empty_explore_btn'),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(
      BuildContext context, SaathiController controller, int index) {
    controller.onItemTapped(index);
    switch (index) {
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