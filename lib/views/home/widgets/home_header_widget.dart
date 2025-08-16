import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../cart/cart_screen.dart';
import '../../../services/SearchScreen.dart';

class HomeHeaderWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const HomeHeaderWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  Widget _buildLocationInfo(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        String cityOnly = '';
        if (viewModel.address.contains(',')) {
          cityOnly = viewModel.address.split(',').last.trim();
        } else {
          cityOnly = viewModel.address.trim();
        }

        return Text(
          '${viewModel.locationLabel}\n$cityOnly',
          style: TextStyle(
            fontSize: 12.sp * scaleFactor,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xFFFFEEE0),
      statusBarIconBrightness: Brightness.dark,
    ));

    return Container(
      color: const Color(0xFFFFEEE0),
      padding: EdgeInsets.only(bottom: 16.r * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location + Cart Row
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 12.h * scaleFactor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/homy.svg',
                      width: 40.w * scaleFactor,
                      height: 40.h * scaleFactor,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8.w * scaleFactor),
                    _buildLocationInfo(context),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/cart.svg',
                    width: 40.w * scaleFactor,
                    height: 40.h * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            },
            child: AbsorbPointer(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: SizedBox(
                  height: 48.h * scaleFactor,
                  child: TextField(
                    style: TextStyle(fontSize: 14.sp * scaleFactor),
                    decoration: InputDecoration(
                      hintText: 'Search for services',
                      prefixIcon: Icon(Icons.search, size: 20 * scaleFactor),
                      filled: true,
                      fillColor: const Color(0xFFF8F6F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h * scaleFactor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}