import 'package:chayankaro/views/profile/aboutscreen.dart';
import '/views/booking/PaymentScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/views/rewards/ReferAndEarnScreen.dart';
import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../booking/booking_screen.dart';
import '../chayan_sathi/chayan_sathi_screen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../profile/EditProfileScreen.dart';
import '../profile/manage_address_screen.dart';
import '../profile/help_screen.dart';
import '../profile/rating_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/chayan_header.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../data/local/database.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 4;
  bool _isLoggingOut = false;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Get.offAll(() => ChayanSathiScreen());
        break;
      case 1:
        Get.offAll(() => BookingScreen());
        break;
      case 2:
        Get.offAll(() => HomeScreen());
        break;
      case 3:
        Get.offAll(() => ReferAndEarnScreen());
        break;
      case 4:
        break;
    }
  }

  // Logout functionality (REMOVED SNACKBAR)
  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;

    // Show confirmation dialog
    final bool? shouldLogout = await _showLogoutConfirmationDialog();
    if (shouldLogout != true) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Get database instance
      final database = Get.find<AppDatabase>();
      
      // Clear authentication data
      await database.clearAuthData();
      
      print('✅ User logged out successfully');
      
      // Navigate to login screen silently (NO SNACKBAR)
      Get.offAllNamed('/login');
      
    } catch (e) {
      print('❌ Error during logout: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Inter',
              color: Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE47830),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // User profile WITHOUT pencil icon/edit functionality
  Widget _buildUserProfile(double scaleFactor) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        final userName = homeController.userName;
        final userPhone = homeController.userPhone;
        
        return Row(
          children: [
            CircleAvatar(
              radius: 40 * scaleFactor,
              backgroundImage: const AssetImage('assets/userprofile.webp'),
            ),
            SizedBox(width: 16.w * scaleFactor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isNotEmpty ? userName : 'Ayush Srivastav (LALA)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp * scaleFactor,
                  ),
                ),
                SizedBox(height: 4.h * scaleFactor),
                Text(
                  userPhone.isNotEmpty ? '+91 $userPhone' : '+91 7355640235',
                  style: TextStyle(
                    fontSize: 12.sp * scaleFactor,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF161616),
                  ),
                ),
                SizedBox(height: 2.h * scaleFactor),
                Opacity(
                  opacity: 0.55,
                  child: Text(
                    '9.9 Rating',
                    style: TextStyle(
                      fontSize: 10.sp * scaleFactor,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF161616),
                    ),
                  ),
                ),
              ],
            ),
            // REMOVED: Pencil icon and edit functionality
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget buildQuickAction(String label, String iconAssetPath, double scaleFactor) {
    return Container(
      width: 97.w * scaleFactor,
      height: 100.h * scaleFactor,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.w * scaleFactor,
            color: const Color(0xB5E47830),
          ),
          borderRadius: BorderRadius.circular(15.r * scaleFactor),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w * scaleFactor, vertical: 10.h * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30.w * scaleFactor,
              height: 30.h * scaleFactor,
              decoration: const ShapeDecoration(
                shape: OvalBorder(),
              ),
              child: SvgPicture.asset(
                iconAssetPath,
                width: 30.w * scaleFactor,
                height: 30.h * scaleFactor,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 8.h * scaleFactor),
            SizedBox(
              height: 36.h * scaleFactor,
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF161616),
                  fontSize: 12.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(String iconPath, String label, double scaleFactor, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w * scaleFactor),
      leading: SvgPicture.asset(
        iconPath,
        width: 20.w * scaleFactor,
        height: 20.h * scaleFactor,
        color: Colors.black,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 16.sp * scaleFactor,
        ),
      ),
      trailing: _isLoggingOut && label == "Logout"
          ? SizedBox(
              width: 16.sp * scaleFactor,
              height: 16.sp * scaleFactor,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFE47830),
                ),
              ),
            )
          : Icon(Icons.arrow_forward_ios, size: 16.sp * scaleFactor),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              ChayanHeader(title: 'Profile', onBackTap: () {}),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                  children: [
                    SizedBox(height: 24.h * scaleFactor),
                    
                    // Updated user profile section (NO PENCIL ICON)
                    _buildUserProfile(scaleFactor),
                    
                    SizedBox(height: 24.h * scaleFactor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => BookingScreen()),
                          child: buildQuickAction("My Bookings", 'assets/icons/bookings.svg', scaleFactor),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const ReferAndEarnScreen()),
                          child: buildQuickAction("Invite Friends", 'assets/icons/refer.svg', scaleFactor),
                        ),
                        GestureDetector(
                          onTap: () => Get.to(() => const HelpScreen()),
                          child: buildQuickAction("Help & Support", 'assets/icons/help.svg', scaleFactor),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h * scaleFactor),
                    const Divider(color: Color(0xFFEBEBEB)),
                    
                    // Menu items
                    buildListItem('assets/icons/location.svg', "Manage Address", scaleFactor, onTap: () {
                      Get.to(() => const ManageAddressScreen());
                    }),
                    buildListItem('assets/icons/rate.svg', "Rate us", scaleFactor, onTap: () {
                      Get.to(() => RatingScreen());
                    }),
                    buildListItem('assets/icons/about.svg', "About Chayan karo Services", scaleFactor, onTap: () {
                      Get.to(() => AboutChaynkaroServicesScreen());
                    }),
                    buildListItem('assets/icons/settings.svg', "Settings", scaleFactor, onTap: () {
                      Get.to(() => const EditProfileScreen());
                    }),
                    
                    // Logout button (REMOVED SNACKBAR)
                    buildListItem(
                      'assets/icons/logout.svg', 
                      "Logout", 
                      scaleFactor, 
                      onTap: _isLoggingOut ? null : _handleLogout,
                    ),
                    
                    SizedBox(height: 20.h * scaleFactor),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const ReferAndEarnScreen());
                      },
                      child: Container(
                        padding: EdgeInsets.all(20.r * scaleFactor),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDE0),
                          borderRadius: BorderRadius.circular(12.r * scaleFactor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Refer & earn 100 coins',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18.sp * scaleFactor,
                                    ),
                                  ),
                                  SizedBox(height: 6.h * scaleFactor),
                                  Text(
                                    'Get 100 coins when your friend completes their first booking',
                                    style: TextStyle(
                                      fontFamily: 'SF Pro',
                                      fontSize: 14.sp * scaleFactor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w * scaleFactor),
                            SvgPicture.asset(
                              'assets/icons/gifty.svg',
                              height: 57.h * scaleFactor,
                              width: 57.w * scaleFactor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h * scaleFactor),
                  ],
                ),
              ),
            ],
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
