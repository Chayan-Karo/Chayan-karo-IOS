import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../data/local/database.dart'; // Import for database access

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false; // Add loading state

  final List<String> _images = [
    "assets/onboard1.webp",
    "assets/onboard2.webp",
    "assets/onboard3.webp",
  ];

  final List<String> _titles = [
    'We Provide Professional Home services at a very friendly price',
    'Easy Service booking & Scheduling',
    'Get Beauty parlor at your home & other Personal Grooming needs',
  ];

  /// Consistent tablet detection
  bool isTablet(BuildContext context) {
    final mq = MediaQuery.of(context);
    final widthDp = mq.size.width;
    final heightDp = mq.size.height;
    final diagonalDp = math.sqrt(math.pow(widthDp, 2) + math.pow(heightDp, 2));

    final isLargeEnough = diagonalDp >= 1100; // ~7" at mdpi
    final isWideEnough = mq.size.shortestSide >= 500;

    debugPrint(
      '[Onboarding Tablet Check] widthDp: $widthDp, heightDp: $heightDp, diagonalDp: $diagonalDp, '
      'isLargeEnough: $isLargeEnough, isWideEnough: $isWideEnough, '
      'tablet: ${isLargeEnough || isWideEnough}',
    );

    return isLargeEnough || isWideEnough;
  }

  void _nextPage() {
    if (_currentPage < _images.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _completeOnboarding(); // Updated to use database method
    }
  }

  void _skip() {
    _completeOnboarding(); // Updated to use database method
  }

  // Complete onboarding with database integration (NO SNACKBARS)
  Future<void> _completeOnboarding() async {
    if (_isLoading) return; // Prevent multiple taps
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Get database instance
      final database = Get.find<AppDatabase>();
      
      // Mark onboarding as completed
      await database.markOnboardingComplete();
      
      print('✅ Onboarding completed successfully');
      
      // Navigate to login screen silently (NO SNACKBAR)
      Get.offAllNamed('/login');
      
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      
      // Navigate anyway on error (NO ERROR SNACKBAR)
      Get.offAllNamed('/login');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

        if (!isTabletDevice) {
          // Phone UI remains unchanged
          final bool tablet = isTablet(context);

          // Sizes change based on tablet detection
          double outerCircleSize = tablet ? 0.6.sw : 0.8.sw;
          double innerCircleSize = tablet ? 0.5.sw : 0.7.sw;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          SizedBox(height: tablet ? 80.h : 100.h),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: outerCircleSize,
                                  width: outerCircleSize,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2F4FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  height: innerCircleSize,
                                  width: innerCircleSize,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE5EAFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _images[index],
                                      width: innerCircleSize,
                                      height: innerCircleSize,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: tablet ? 30.h : 40.h),
                          Text(
                            _titles[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF1A1D1F),
                              fontSize: tablet ? 34.sp : 28.sp,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Skip Button with loading state
                Positioned(
                  top: 50.h,
                  right: 24.w,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _skip,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: _isLoading 
                            ? const Color(0xFFE6EAFF).withOpacity(0.5)
                            : const Color(0xFFE6EAFF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFFF6F00),
                                ),
                              ),
                            )
                          : Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'SFProSemibold',
                                color: const Color(0xFFFF6F00),
                              ),
                            ),
                    ),
                  ),
                ),

                // Bottom Controls with loading state
                Positioned(
                  bottom: 0.h,
                  left: 0.w,
                  right: 0.w,
                  child: SafeArea(
                    minimum: EdgeInsets.only(bottom: 28.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _isLoading ? null : _nextPage,
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isLoading 
                                  ? const Color(0xFFFF6F00).withOpacity(0.5)
                                  : const Color(0xFFFF6F00),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 28.sp,
                                    height: 28.sp,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _currentPage == _images.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (index) => buildDot(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Tablet UI with scaling applied
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _images.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    // Use tablet sizing for larger screens
                    double outerCircleSize = 0.6.sw * scaleFactor;
                    double innerCircleSize = 0.5.sw * scaleFactor;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w * scaleFactor),
                      child: Column(
                        children: [
                          SizedBox(height: 80.h * scaleFactor),
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: outerCircleSize,
                                  width: outerCircleSize,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF2F4FF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Container(
                                  height: innerCircleSize,
                                  width: innerCircleSize,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE5EAFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      _images[index],
                                      width: innerCircleSize,
                                      height: innerCircleSize,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h * scaleFactor),
                          Text(
                            _titles[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF1A1D1F),
                              fontSize: 34.sp * scaleFactor,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Skip Button - Scaled for tablets with loading state
                Positioned(
                  top: 50.h * scaleFactor,
                  right: 24.w * scaleFactor,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _skip,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w * scaleFactor,
                        vertical: 8.h * scaleFactor,
                      ),
                      decoration: BoxDecoration(
                        color: _isLoading 
                            ? const Color(0xFFE6EAFF).withOpacity(0.5)
                            : const Color(0xFFE6EAFF),
                        borderRadius: BorderRadius.circular(20.r * scaleFactor),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16.w * scaleFactor,
                              height: 16.h * scaleFactor,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFFFF6F00),
                                ),
                              ),
                            )
                          : Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontFamily: 'SFProSemibold',
                                color: const Color(0xFFFF6F00),
                              ),
                            ),
                    ),
                  ),
                ),

                // Bottom Controls - Scaled for tablets with loading state
                Positioned(
                  bottom: 0.h,
                  left: 0.w,
                  right: 0.w,
                  child: SafeArea(
                    minimum: EdgeInsets.only(bottom: 28.h * scaleFactor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _isLoading ? null : _nextPage,
                          child: Container(
                            padding: EdgeInsets.all(16.r * scaleFactor),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isLoading 
                                  ? const Color(0xFFFF6F00).withOpacity(0.5)
                                  : const Color(0xFFFF6F00),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 28.sp * scaleFactor,
                                    height: 28.sp * scaleFactor,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    _currentPage == _images.length - 1
                                        ? Icons.check
                                        : Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 28.sp * scaleFactor,
                                  ),
                          ),
                        ),
                        SizedBox(height: 12.h * scaleFactor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _images.length,
                            (index) => buildDot(index, scaleFactor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildDot(int index, [double scaleFactor = 1.0]) {
    return Container(
      height: 8.h * scaleFactor,
      width: _currentPage == index ? 24.w * scaleFactor : 8.w * scaleFactor,
      margin: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r * scaleFactor),
        color: _currentPage == index
            ? const Color(0xFFFF6F00)
            : Colors.grey.shade300,
      ),
    );
  }
}
