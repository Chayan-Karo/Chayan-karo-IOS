import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// Import the Service model
import '../../models/home_models.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/common_top_bar.dart';

class AllMostUsedServicesScreen extends StatelessWidget {
  // Updated to use typed Service model instead of Map
  final List<Service> mostUsedServices;

  const AllMostUsedServicesScreen({
    super.key, 
    required this.mostUsedServices,
  });

  void _onItemTapped(BuildContext context, int index) {
    // ✅ FIXED: Use GetX navigation instead of Navigator.pop
    switch (index) {
      case 0:
        Get.offAllNamed('/chayan-sathi'); // Replace with your route
        break;
      case 1:
        Get.offAllNamed('/bookings'); // Replace with your route
        break;
      case 2:
        Get.back(); // Go back to home screen
        break;
      case 3:
        Get.offAllNamed('/rewards'); // Replace with your route
        break;
      case 4:
        Get.offAllNamed('/profile'); // Replace with your route
        break;
      default:
        Get.back(); // Fallback to go back
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        // ✅ IMPROVED: Better responsive scaling
        double gridSpacing = isTablet ? 20.w : 16.w;
        double gridPadding = isTablet ? 24.w : 16.w;
        double titleFontSize = isTablet ? 16.sp : 14.sp;
        double ratingFontSize = isTablet ? 14.sp : 12.sp;
        double oldPriceFontSize = isTablet ? 14.sp : 12.sp;
        double newPriceFontSize = isTablet ? 16.sp : 14.sp;
        double imageHeight = isTablet ? 140.h : 110.h;
        double cardRadius = isTablet ? 16 : 12;
        double starSize = isTablet ? 16.h : 14.h;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: SafeArea(
            child: Column(
              children: [
                const CommonTopBar(
                  title: 'Most used services',
                  showShareIcon: true,
                ),
                SizedBox(height: 12.h * scaleFactor),

                // ✅ IMPROVED: Better empty state design
                if (mostUsedServices.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(32.r),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cleaning_services_outlined,
                              size: 64.sp * scaleFactor,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 24.h * scaleFactor),
                          Text(
                            'No services available',
                            style: TextStyle(
                              fontSize: 20.sp * scaleFactor,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.h * scaleFactor),
                          Text(
                            'Check back later for new services',
                            style: TextStyle(
                              fontSize: 16.sp * scaleFactor,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 32.h * scaleFactor),
                          // ✅ NEW: Add a "Go Back" button for better UX
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6F00),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w * scaleFactor,
                                vertical: 12.h * scaleFactor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Go Back',
                              style: TextStyle(
                                fontSize: 16.sp * scaleFactor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // ✅ IMPROVED: Grid of Services with better responsiveness
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: gridPadding),
                      child: GridView.builder(
                        itemCount: mostUsedServices.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2, // More columns for tablets
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          childAspectRatio: isTablet ? 0.75 : 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final service = mostUsedServices[index];
                          
                          return GestureDetector(
                            onTap: () {
                              // ✅ NEW: Add service tap functionality with feedback
                              Get.snackbar(
                                'Service Selected',
                                '${service.title} tapped',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFF6F00),
                                colorText: Colors.white,
                                duration: Duration(seconds: 1),
                              );
                              // TODO: Navigate to service details page
                              // Get.to(() => ServiceDetailsScreen(service: service));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(cardRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ IMPROVED: Service Image with Hero animation
                                  Hero(
                                    tag: 'service_${service.title}_$index',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(cardRadius),
                                      ),
                                      child: Image.asset(
                                        service.image,
                                        width: double.infinity,
                                        height: imageHeight,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: double.infinity,
                                            height: imageHeight,
                                            color: Colors.grey[200],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.cleaning_services,
                                                  color: const Color(0xFFFF6F00),
                                                  size: 32.sp * scaleFactor,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  'Image not found',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  // ✅ IMPROVED: Service Details with better spacing
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(12.r * scaleFactor),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Service Title
                                          Text(
                                            service.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: titleFontSize,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'SFPro',
                                              height: 1.3,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          
                                          // Bottom section with rating and price
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 6.h * scaleFactor),
                                              
                                              // Rating Row
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/star.svg',
                                                    height: starSize,
                                                    width: starSize,
                                                    colorFilter: const ColorFilter.mode(
                                                      Colors.amber,
                                                      BlendMode.srcIn,
                                                    ),
                                                    placeholderBuilder: (_) => Icon(
                                                      Icons.star,
                                                      size: starSize,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4.w * scaleFactor),
                                                  Expanded(
                                                    child: Text(
                                                      '4.8 (23k)', // Can be made dynamic later
                                                      style: TextStyle(
                                                        fontSize: ratingFontSize,
                                                        color: Colors.black54,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              
                                              SizedBox(height: 8.h * scaleFactor),
                                              
                                              // Price Row
                                              Row(
                                                children: [
                                                  Text(
                                                    '₹799',
                                                    style: TextStyle(
                                                      fontSize: oldPriceFontSize,
                                                      decoration: TextDecoration.lineThrough,
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w * scaleFactor),
                                                  Expanded(
                                                    child: Text(
                                                      '₹499',
                                                      style: TextStyle(
                                                        fontSize: newPriceFontSize,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xFFFF6F00),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ✅ IMPROVED: Bottom Navigation Bar with correct index
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 2, // Home tab selected
            onItemTapped: (index) => _onItemTapped(context, index),
          ),
        );
      },
    );
  }
}
