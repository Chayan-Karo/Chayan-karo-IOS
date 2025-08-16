import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ViewModels
import '../../viewmodels/home_viewmodel.dart';

// Widgets
import './widgets/home_header_widget.dart';
import './widgets/categories_grid_widget.dart';
import './widgets/home_banner_widget.dart';
import './widgets/service_section_widget.dart';
import './widgets/most_used_services_widget.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

// Screens
import '../chayan_sathi/chayan_sathi_screen.dart';
import '../booking/booking_screen.dart';
import '../rewards/rewards_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChayanSathiScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => RewardsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth >= 600;
              final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;
              final mediaQuery = MediaQuery.of(context);

              final horizontalPadding = 16.w * scaleFactor;
              final bottomPadding = mediaQuery.padding.bottom + 
                  (isTablet ? 90.h * scaleFactor : 70.h * scaleFactor);

              // Show loading indicator
              if (viewModel.isLoading) {
                return Scaffold(
                  backgroundColor: const Color(0xFFFDFDFD),
                  body: const Center(child: CircularProgressIndicator()),
                );
              }

              return Scaffold(
                backgroundColor: const Color(0xFFFDFDFD),
                body: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomPadding),
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

                        // Services Section
                        ServiceSectionWidget(
                          title: 'Your go-to services',
                          scaleFactor: scaleFactor,
                        ),

                        SizedBox(height: 24.h * scaleFactor),

                        // Most Used Services
                        MostUsedServicesWidget(scaleFactor: scaleFactor),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              );
            },
          );
        },
      ),
    );
  }
}