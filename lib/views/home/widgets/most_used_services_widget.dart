import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../all_most_used_services/all_most_used_services_screen.dart';
import './horizontal_service_scroll.dart';
import './appliances_repairs_section.dart';
import './salon_men_section.dart';
import './ac_repair_section.dart';
import './male_spa_section.dart';
import './spa_women_section.dart';
import './saloon_women_section.dart';

class MostUsedServicesWidget extends StatelessWidget {
  final double scaleFactor;

  const MostUsedServicesWidget({
    Key? key,
    required this.scaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return _buildMostUsedServices(context, viewModel);
      },
    );
  }

  Widget _buildMostUsedServices(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0 * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Most used services',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp * scaleFactor,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllMostUsedServicesScreen(
                        mostUsedServices: viewModel.mostUsedServices,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16 * scaleFactor),
                  child: Text(
                    'View all >',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14.sp * scaleFactor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h * scaleFactor),

          // Horizontal Services Scroll
          const HorizontalServiceScroll(),

          SizedBox(height: 24.h * scaleFactor),
          const SaloonWomenSection(),
          SizedBox(height: 24.h * scaleFactor),
          const SpaWomenSection(),
          SizedBox(height: 24.h * scaleFactor),
          const MaleSpaSection(),
          SizedBox(height: 24.h * scaleFactor),
          const SalonMenSection(),
          SizedBox(height: 24.h * scaleFactor),
          const ACRepairSection(),
          SizedBox(height: 24.h * scaleFactor),
          const AppliancesRepairsSection(),
          SizedBox(height: 24.h * scaleFactor),
        ],
      ),
    );
  }
}