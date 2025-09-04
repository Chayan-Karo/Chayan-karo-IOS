import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../booking/booking_screen.dart';
import '../rewards/ReferAndEarnScreen.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/saathi_controller.dart';

class ChayanSathiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SaathiController(),
      child: Consumer<SaathiController>(
        builder: (context, controller, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

              return Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    /// Header
                    ChayanHeader(
                      title: 'Chayan Saathi',
                      onBackTap: () => Navigator.pop(context),
                    ),

                    /// Grid content
                    Expanded(
                      child: GridView.builder(
                              padding: EdgeInsets.fromLTRB(
                                16.h * scaleFactor,
                                16.h * scaleFactor,
                                16.h * scaleFactor,
                                90.h * scaleFactor,
                              ),
                              itemCount: controller.saathiList.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12 * scaleFactor,
                                mainAxisSpacing: 12 * scaleFactor,
                                childAspectRatio: 0.68,
                              ),
                              itemBuilder: (context, index) {
                                final saathi = controller.saathiList[index];
                                return _buildSaathiCard(saathi, scaleFactor);
                              },
                            ),
                    ),
                  ],
                ),
                bottomNavigationBar: CustomBottomNavBar(
                  selectedIndex: controller.selectedIndex,
                  onItemTapped: (index) => _onItemTapped(context, controller, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSaathiCard(Map<String, dynamic> saathi, double scaleFactor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15 * scaleFactor),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15.h * scaleFactor),
            ),
            child: Image.asset(
              saathi["image"],
              height: 140.h * scaleFactor,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 8.h * scaleFactor),

          /// Name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Text(
              saathi["name"],
              style: TextStyle(
                fontFamily: 'SFProSemibold',
                fontSize: 14.sp * scaleFactor,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 6.h * scaleFactor),

          /// Jobs row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0.w * scaleFactor),
            child: Row(
              children: [
                Transform.translate(
                  offset: Offset(-2.w * scaleFactor, 0),
                  child: SvgPicture.asset(
                    'assets/icons/tick.svg',
                    width: 14.w * scaleFactor,
                    height: 14.h * scaleFactor,
                  ),
                ),
                SizedBox(width: 4.w * scaleFactor),
                Text(
                  "${saathi["jobs"]} jobs completed",
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

          /// Rating row
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
                  "${saathi["rating"]}",
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.sp * scaleFactor,
                    color: Colors.black,
                  ),
                ),
                Text(
                  " (23k)",
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 12.sp * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(BuildContext context, SaathiController controller, int index) {
    controller.onItemTapped(index);
    
    switch (index) {
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReferAndEarnScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        break;
    }
  }
}
