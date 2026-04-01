import 'package:chayankaro/views/chayan_sathi/previouschayansathiscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

// Controllers
import '../../controllers/home_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/profile_controller.dart'; // <-- NEW

// Widgets
import './widgets/home_header_widget.dart';
import './widgets/categories_grid_widget.dart';
import './widgets/home_banner_widget.dart';
import './widgets/most_used_services_widget.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../data/local/database.dart';

// Screens
import '../chayan_sathi/chayan_sathi_screen.dart';
import '../booking/booking_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../profile/profile_screen.dart';
import '../../controllers/booking_read_controller.dart'; // <--- ADD THIS
import './widgets/exit_app_dialog.dart';  // <--- ADD THIS
// Repositories
import '../../data/repository/location_repository.dart';
import '../../controllers/service_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    // Initialize controllers immediately - no postFrameCallback delay
    try {
      Get.find<HomeController>();
      Get.find<CartController>();
      Get.find<CategoryController>();
      Get.put(BookingReadController()); // <--- ADD THIS LINE
      print('✅ HomeScreen: Controllers initialized successfully');
    } catch (e) {
      print('❌ HomeScreen: Error initializing controllers: $e');
    }

   Future.microtask(() async {
    try {
      final database = Get.find<AppDatabase>();
      final bool isLoggedIn = await database.isUserLoggedIn();

      // 🛑 EXIT EARLY IF GUEST
      if (!isLoggedIn) {
        print('👤 Home: Guest Mode - Skipping Profile & Address checks');
        return;
      }

      // 🔐 LOGGED-IN ONLY LOGIC
      print('🔐 Home: Auth User - Loading Profile and Address');
      final profileController = Get.put(ProfileController(), permanent: true);
      await profileController.loadProfile();

      // 1) Enforce basic info
      if (!profileController.isBasicInfoComplete) {
        Get.offAllNamed('/edit-profile', arguments: profileController.customer);
        return;
      }

      // 2) Enforce address presence
      final repo = Get.find<LocationRepository>();
      final list = await repo.getCustomerAddresses();
      if (list.isEmpty) {
        Get.offAllNamed('/location_popup');
        return;
      }

      // 3) Check for feedback (Authenticated only)
      Get.find<BookingReadController>().checkForPendingFeedback();
      
    } catch (e) {
      print('❌ Home Auth Check Error: $e');
      // On error for logged-in users, fallback to location is safer
      // But for guests, this block isn't even reached.
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

 void _onItemTapped(BuildContext context, int index) {
    if (index == 2) return;

    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.to(() => PreviousChayanSathiScreen());
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

return PopScope(
  canPop: false,
  onPopInvoked: (didPop) async {
    if (didPop) return;
    await showExitAppDialog(context);
  },
  child: Scaffold(  backgroundColor: const Color(0xFFFDFDFD),

  // ✅ STATUS BAR COLOR WITHOUT LAYOUT IMPACT
  appBar: PreferredSize(
    preferredSize: Size.fromHeight(0),
    child: AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFFFEEE0), // your color
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFFEEE0),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
  ),

  body: RefreshIndicator(
    onRefresh: () async {
      final categoryController = Get.find<CategoryController>();
      final homeController = Get.find<HomeController>();
      final cartController = Get.find<CartController>();
      final serviceController = Get.find<ServiceController>();

      await Future.wait([
        categoryController.refreshCategories(),
        homeController.refreshData(),
     
      ]);

      cartController.refreshCart();
      
    },
    child: SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RepaintBoundary(
            child: HomeHeaderWidget(
              scaleFactor: scaleFactor,
              horizontalPadding: horizontalPadding,
            ),
          ),

          SizedBox(height: 16.h * scaleFactor),

          RepaintBoundary(
            child: CategoriesGridWidget(
              scaleFactor: scaleFactor,
              horizontalPadding: horizontalPadding,
            ),
          ),

          SizedBox(height: 20.h * scaleFactor),

          RepaintBoundary(
            child: HomeBannerWidget(
              scaleFactor: scaleFactor,
              horizontalPadding: horizontalPadding,
            ),
          ),

          SizedBox(height: 24.h * scaleFactor),

          RepaintBoundary(
            child: MostUsedServicesWidget(scaleFactor: scaleFactor),
          ),

          //SizedBox(height: bottomPadding),
        ],
      ),
    ),
  ),

  bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2, // Hardcoded 2
        onItemTapped: (index) => _onItemTapped(context, index), // Correct call
      ),
)
);

      },
    );
  }
}
