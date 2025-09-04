import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet detection
        final bool isTablet = constraints.maxWidth > 600;
        // Limit max scale factor to prevent overflow on huge tablets
        final double scaleFactor = isTablet
            ? (constraints.maxWidth / 411).clamp(1.0, 1.5) // max 1.5x scale
            : 1.0;

        return Container(
          padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 8.h * scaleFactor),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEFD),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFFA9441),
                width: 0.5.w * scaleFactor,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, -1),
              ),
            ],
          ),
          child: SizedBox(
            height: 70.h * scaleFactor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem('assets/icons/chayansathi.svg', 'Chayan Sathi', 0, scaleFactor),
                _buildNavItem('assets/icons/bookings.svg', 'Bookings', 1, scaleFactor),
                _buildCenterNavItem('assets/icons/chayankaro.jpg', 'Chayan Karo', 2, scaleFactor),
                _buildNavItem('assets/icons/refer.svg', 'Referral', 3, scaleFactor),
                _buildNavItem('assets/icons/profile.svg', 'Profile', 4, scaleFactor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(String iconPath, String label, int index, double scaleFactor) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: isActive
                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            child: iconPath.endsWith('.svg')
                ? SvgPicture.asset(
                    iconPath,
                    width: 40.w * scaleFactor,
                    height: 40.h * scaleFactor,
                    color: isActive ? null : Colors.black,
                  )
                : Image.asset(
                    iconPath,
                    width: 40.w * scaleFactor,
                    height: 40.h * scaleFactor,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(height: 2.h * scaleFactor),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp * scaleFactor,
              height: 2.h * scaleFactor,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(String iconPath, String label, int index, double scaleFactor) {
    final bool isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40.h * scaleFactor,
            child: Center(
              child: Container(
                width: 24.45.w * scaleFactor,
                height: 23.8.h * scaleFactor,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2 * scaleFactor),
                  image: DecorationImage(
                    image: AssetImage(iconPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h * scaleFactor),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp * scaleFactor,
              height: 2.h * scaleFactor,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
