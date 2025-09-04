import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Controllers
import '../../controllers/home_controller.dart';
import '../../controllers/cart_controller.dart';

// Widgets
import './widgets/home_header_widget.dart';
import './widgets/categories_grid_widget.dart';
import './widgets/home_banner_widget.dart';
import './widgets/most_used_services_widget.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

// Screens
import '../chayan_sathi/chayan_sathi_screen.dart';
import '../booking/booking_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    
    // Add lifecycle observer to detect app resume
    WidgetsBinding.instance.addObserver(this);
    
    // Ensure controllers are initialized immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.find<HomeController>();
        Get.find<CartController>();
        print('✅ Controllers initialized successfully');
      } catch (e) {
        print('❌ Error initializing controllers: $e');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      print('🏠 App resumed - refreshing cart');
      try {
        final cartController = Get.find<CartController>();
        cartController.refreshCart();
      } catch (e) {
        print('❌ Error refreshing cart: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.to(() => ChayanSathiScreen());
        break;
      case 1:
        Get.to(() => BookingScreen());
        break;
      case 3:
        Get.to(() => ReferAndEarnScreen());
        break;
      case 4:
        Get.to(() => ProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth >= 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;
        final mediaQuery = MediaQuery.of(context);

        final horizontalPadding = 16.w * scaleFactor;
        final bottomPadding = mediaQuery.padding.bottom + 
            (isTablet ? 90.h * scaleFactor : 70.h * scaleFactor);

        return Scaffold(
          backgroundColor: const Color(0xFFFDFDFD),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Loading state with animated three dots
                Obx(() {
                  final homeController = Get.find<HomeController>();
                  
                  if (homeController.isLoading) {
                    return Expanded(
                      child: Center(
                        child: LoadingDotsAnimation(
                          scaleFactor: scaleFactor,
                        ),
                      ),
                    );
                  }
                  
                  // Show main content when not loading
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        final cartController = Get.find<CartController>();
                        await homeController.refreshData();
                        cartController.refreshCart();
                      },
                      child: SingleChildScrollView(
                        //padding: EdgeInsets.only(bottom: bottomPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            HomeHeaderWidget(
                              scaleFactor: scaleFactor,
                              horizontalPadding: horizontalPadding,
                            ),

                            SizedBox(height: 16.h * scaleFactor),

                            // Categories Grid
                            CategoriesGridWidget(
                              scaleFactor: scaleFactor,
                              horizontalPadding: horizontalPadding,
                            ),

                            SizedBox(height: 20.h * scaleFactor),

                            // Banner
                            HomeBannerWidget(
                              scaleFactor: scaleFactor,
                              horizontalPadding: horizontalPadding,
                            ),

                            SizedBox(height: 24.h * scaleFactor),


                            // Most Used Services
                            MostUsedServicesWidget(scaleFactor: scaleFactor),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        );
      },
    );
  }
}

// NEW: Three-dot loading animation widget
class LoadingDotsAnimation extends StatefulWidget {
  final double scaleFactor;
  
  const LoadingDotsAnimation({
    Key? key,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  @override
  State<LoadingDotsAnimation> createState() => _LoadingDotsAnimationState();
}

class _LoadingDotsAnimationState extends State<LoadingDotsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create staggered animations for each dot
    _dot1Animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _dot2Animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.5, curve: Curves.easeInOut),
      ),
    );

    _dot3Animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Start the animation and repeat
    _controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Three animated dots
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(_dot1Animation.value),
                SizedBox(width: 8.w * widget.scaleFactor),
                _buildDot(_dot2Animation.value),
                SizedBox(width: 8.w * widget.scaleFactor),
                _buildDot(_dot3Animation.value),
              ],
            );
          },
        ),
        
        SizedBox(height: 24.h * widget.scaleFactor),
        
        // Loading text
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 16.sp * widget.scaleFactor,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w500,
            color: const Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(double opacity) {
    return Container(
      width: 12.w * widget.scaleFactor,
      height: 12.h * widget.scaleFactor,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6F00).withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
