import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';
import '../booking/booking_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/rewards_screen.dart';
import '../chayan_sathi/chayan_sathi_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _selectedIndex = -2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChayanSathiScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => RewardsScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
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
          final screenHeight = MediaQuery.of(context).size.height;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: const Color(0xFFFFEEE0),
              statusBarIconBrightness: Brightness.dark,
            ),
            child: Container(
              color: const Color(0xFFFFEEE0),
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEEE0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: ChayanHeader(
                          title: 'Cart',
                          onBackTap: () => Navigator.pop(context),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: screenHeight * 0.75.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 110.w,
                                  height: 110.h,
                                  child: ClipOval(
                                    child: SvgPicture.asset(
                                      "assets/icons/cart_empty.svg",
                                      fit: BoxFit.cover,
                                      width: 110.w,
                                      height: 110.h,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text('Your Cart is Empty',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'SF Pro',
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Opacity(opacity: 0.8,
                                  child: Text(
                                    'Lets add some services',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'SF Pro',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: 175.w,
                                    height: 45.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE47830),
                                        width: 2.w,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text('Explore Services',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'SF Pro',
                                        color: Color(0xFFE47830),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ),
            ),
          );
        } else {
          // Tablet UI with scaling and proper centering
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: const Color(0xFFFFEEE0),
              statusBarIconBrightness: Brightness.dark,
            ),
            child: Container(
              color: const Color(0xFFFFEEE0),
              child: Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFEEE0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 4 * scaleFactor,
                              offset: Offset(0, 2 * scaleFactor),
                            )
                          ],
                        ),
                        child: ChayanHeader(
                          title: 'Cart',
                          onBackTap: () => Navigator.pop(context),
                        ),
                      ),

                      // FIXED: Use Expanded with Center to ensure perfect centering
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 110.w * scaleFactor,
                                height: 110.h * scaleFactor,
                                child: ClipOval(
                                  child: SvgPicture.asset(
                                    "assets/icons/cart_empty.svg",
                                    fit: BoxFit.cover,
                                    width: 110.w * scaleFactor,
                                    height: 110.h * scaleFactor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h * scaleFactor),
                              Text('Your Cart is Empty',
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
                                  'Lets add some services',
                                  style: TextStyle(
                                    fontSize: 20.sp * scaleFactor,
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
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
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
                                  child: Text('Explore Services',
                                    style: TextStyle(
                                      fontSize: 16.sp * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'SF Pro',
                                      color: Color(0xFFE47830),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
