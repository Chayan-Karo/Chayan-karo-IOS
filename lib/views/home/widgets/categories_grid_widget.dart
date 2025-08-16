import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../services/saloonservicescreen.dart';
import '../../../services/SalonMenServiceScreen.dart';
import '../../../services/HairSkinScreen.dart';
import '../../../services/MaleSpaScreen.dart';
import '../../../services/ACServicesScreen.dart';
import '../../../services/CleaningScreen.dart';
import '../../../services/HomeRepairsScreen.dart';
import '../../../services/FemaleSpaScreen.dart';

class CategoriesGridWidget extends StatelessWidget {
  final double scaleFactor;
  final double horizontalPadding;

  const CategoriesGridWidget({
    Key? key,
    required this.scaleFactor,
    required this.horizontalPadding,
  }) : super(key: key);

  void _navigateToService(BuildContext context, String title) {
    switch (title) {
      case 'Female Saloon':
        Navigator.push(context, MaterialPageRoute(builder: (_) => SalonServiceScreen()));
        break;
      case 'Male Saloon':
        Navigator.push(context, MaterialPageRoute(builder: (_) => SalonMenServiceScreen()));
        break;
      case 'Female Spa':
        Navigator.push(context, MaterialPageRoute(builder: (_) => FemaleSpaScreen()));
        break;
      case 'Male Spa':
        Navigator.push(context, MaterialPageRoute(builder: (_) => MaleSpaScreen()));
        break;
      case 'Hair & Skin':
        Navigator.push(context, MaterialPageRoute(builder: (_) => HairSkinScreen()));
        break;
      case 'Home Repairs':
        Navigator.push(context, MaterialPageRoute(builder: (_) => HomeRepairsScreen()));
        break;
      case 'Cleaning':
        Navigator.push(context, MaterialPageRoute(builder: (_) => CleaningScreen()));
        break;
      case 'AC Services':
        Navigator.push(context, MaterialPageRoute(builder: (_) => ACServicesScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 14.h * scaleFactor,
              crossAxisSpacing: 12.w * scaleFactor,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (_, index) {
              final cat = viewModel.categories[index];
              return GestureDetector(
                onTap: () => _navigateToService(context, cat['title']!),
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.w * scaleFactor, color: const Color(0xFFFFD9BE)),
                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: Color(0xFFF2C4A5),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          cat['icon']!,
                          width: 40.w * scaleFactor,
                          height: 40.h * scaleFactor,
                        ),
                        SizedBox(height: 6.h * scaleFactor),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w * scaleFactor),
                          child: Text(
                            cat['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9.sp * scaleFactor,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}