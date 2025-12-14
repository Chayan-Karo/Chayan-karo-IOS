import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/category_models.dart';
import '../../models/service_models.dart';
import '../../data/repository/service_repository.dart';
import '../../services/universal_service_screen.dart';
import '../cart/cart_screen.dart';

import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/common_top_bar.dart';

class AllMostUsedServicesScreen extends StatefulWidget {
  const AllMostUsedServicesScreen({super.key});

  @override
  State<AllMostUsedServicesScreen> createState() =>
      _AllMostUsedServicesScreenState();
}

class _AllMostUsedServicesScreenState extends State<AllMostUsedServicesScreen> {
  final RxList<Service> _combinedServices = <Service>[].obs;
  final RxBool _isLoading = true.obs;
  Category? _targetCategory;

  // Theme Color
  final Color _themeOrange = const Color(0xFFE47830);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFetch();
    });
  }

  void _initFetch() {
    final categoryController = Get.find<CategoryController>();

    // 1. Find the specific parent category (Female Salon)
    _targetCategory =
        categoryController.filteredCategories.firstWhereOrNull((cat) {
      final name = cat.categoryName.toLowerCase();
      return (name.contains('women') || name.contains('female')) &&
          (name.contains('salon') ||
              name.contains('saloon') ||
              name.contains('spa'));
    });

    // 2. Fetch services based on sub-categories of that parent
    if (_targetCategory != null &&
        _targetCategory!.serviceCategory.isNotEmpty) {
      final List<String> allSubCatIds = _targetCategory!.serviceCategory
          .map((e) => e.serviceCategoryId)
          .toList();
      _fetchAllSubCategoryServices(allSubCatIds);
    } else {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchAllSubCategoryServices(List<String> subCategoryIds) async {
    final repo = Get.put(ServiceRepository());
    _isLoading.value = true;
    List<Service> allResults = [];

    try {
      for (String id in subCategoryIds) {
        try {
          final services = await repo.getServices(id);
          allResults.addAll(services);
        } catch (e) {
          debugPrint("⚠️ Error fetching sub-category $id: $e");
        }
      }
      final uniqueServices =
          {for (var s in allResults) s.id: s}.values.toList();
      _combinedServices.assignAll(uniqueServices);
    } catch (e) {
      debugPrint("❌ Critical error fetching services: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  void _navigateToService(Service service) {
    if (_targetCategory != null) {
      Get.to(() => CategoryServiceScreen(
            category: _targetCategory!,
            scrollToServiceCategoryId: service.categoryId,
          ));
    } else {
      Get.snackbar('Error', 'Service category not found');
    }
  }

  // ✅ DYNAMIC SHARE ANIMATION
  void _handleShare() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(height: 20.h),
            Text("Share Services",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.copy, "Copy Link"),
                _buildShareOption(Icons.message, "WhatsApp"),
                _buildShareOption(Icons.share, "More"),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      enterBottomSheetDuration: const Duration(milliseconds: 400),
      isDismissible: true,
    );
  }

  Widget _buildShareOption(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: _themeOrange.withOpacity(0.1),
          child: Icon(icon, color: _themeOrange, size: 28),
        ),
        SizedBox(height: 8.h),
        Text(label,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed('/chayan-sathi');
        break;
      case 1:
        Get.offAllNamed('/bookings');
        break;
      case 2:
        Get.back();
        break;
      case 3:
        Get.offAllNamed('/rewards');
        break;
      case 4:
        Get.offAllNamed('/profile');
        break;
      default:
        Get.back();
    }
  }

  bool _isSvgUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.path.toLowerCase().endsWith('.svg');
    } catch (e) {
      return url.toLowerCase().contains('.svg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        double gridSpacing = isTablet ? 20.w : 16.w;
        double gridPadding = isTablet ? 24.w : 16.w;
        double titleFontSize = isTablet ? 15.sp : 13.sp;
        double ratingFontSize = isTablet ? 13.sp : 11.sp;
        double oldPriceFontSize = isTablet ? 13.sp : 11.sp;
        double newPriceFontSize = isTablet ? 15.sp : 14.sp;
        double imageHeight = isTablet ? 140.h : 115.h;
        double cardRadius = isTablet ? 16 : 16;
        double starSize = isTablet ? 16.h : 14.h;

        return Scaffold(
          backgroundColor:
              const Color(0xFFF8F9FA), // Slightly lighter background
          body: SafeArea(
            child: Column(
              children: [
                // ✅ TOP BAR
                GestureDetector(
                  onTap: () {
                    // Handle share area tap if needed
                  },
                  child: CommonTopBar(
                    title: 'Most Used Services',
                    //showShareIcon: true,
                    // Pass _handleShare if CommonTopBar supports onShareTap
                  ),
                ),
                SizedBox(height: 12.h * scaleFactor),
                Expanded(
                  child: Obx(() {
                    if (_isLoading.value) {
                      return Center(
                          child: CircularProgressIndicator(color: _themeOrange));
                    }

                    if (_combinedServices.isEmpty) {
                      return Center(
                        child: Text(
                          'No services available',
                          style: TextStyle(
                              fontSize: 18.sp, color: Colors.grey[700]),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: gridPadding),
                      child: GridView.builder(
                        itemCount: _combinedServices.length,
                        padding: EdgeInsets.only(bottom: 20.h),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          mainAxisSpacing: gridSpacing,
                          crossAxisSpacing: gridSpacing,
                          childAspectRatio: isTablet ? 0.72 : 0.68,
                        ),
                        itemBuilder: (context, index) {
                          final service = _combinedServices[index];

                          // 💰 Fake Original Price Logic
                          double originalPriceVal;
                          if (service.discountPercentage > 0) {
                            originalPriceVal = service.price /
                                ((100 - service.discountPercentage) / 100);
                          } else {
                            originalPriceVal = service.price * 1.25;
                          }
                          final int finalOldPrice = originalPriceVal.toInt();

                          return GestureDetector(
                            onTap: () => _navigateToService(service),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(cardRadius),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.15)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🖼️ Image with Discount Tag
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(cardRadius),
                                        ),
                                        child: _buildServiceImage(
                                            service.imgLink,
                                            imageHeight,
                                            scaleFactor),
                                      ),
                                      if (service.discountPercentage > 0)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 6.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${service.discountPercentage.toInt()}% OFF',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                                color: _themeOrange,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  // 📝 Details
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(10.r * scaleFactor),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: titleFontSize,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Inter',
                                                  height: 1.2,
                                                  color:
                                                      const Color(0xFF2D2D2D),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: 4.h * scaleFactor),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/icons/star.svg',
                                                    height: starSize,
                                                    width: starSize,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                          Colors.black,
                                                            BlendMode.srcIn),
                                                    placeholderBuilder: (_) =>
                                                        Icon(Icons.star,
                                                            size: starSize,
                                                            color:
                                                                Colors.amber),
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    '4.8 (2.3k)',
                                                    style: TextStyle(
                                                        fontSize:
                                                            ratingFontSize,
                                                        color:
                                                            Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          // 💰 Price & Add Button Row
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '₹$finalOldPrice',
                                                    style: TextStyle(
                                                      fontSize:
                                                          oldPriceFontSize,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey[400],
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    '₹${service.price.toInt()}',
                                                    style: TextStyle(
                                                      fontSize:
                                                          newPriceFontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // ✅ UPDATED ADD BUTTON LOGIC
                                              InkWell(
                                                onTap: () {
                                                  // 1. SAFETY CHECK
                                                  if (_targetCategory == null) {
                                                    Get.snackbar("Error",
                                                        "Category information missing");
                                                    return;
                                                  }

                                                  // 2. EXTRACT PARENT CATEGORY DETAILS
                                                  final String parentCatId =
                                                      _targetCategory!
                                                          .categoryId;
                                                  final String parentCatName =
                                                      _targetCategory!
                                                          .categoryName;

                                                  // 3. CREATE CART ITEM
                                                  final item =
                                                      CartItem.fromService(
                                                    service,
                                                    sourcePage:
                                                        'most_used_services_screen',
                                                    sourceTitle: parentCatName,
                                                  ).copyWith(
                                                    categoryId:
                                                        parentCatId, // Forces the Parent ID
                                                  );

                                                  // 4. ADD TO CART
                                                  cartController.addItem(item);

                                                  // 5. SUCCESS SNACKBAR
                                                  Get.snackbar(
                                                    "",
                                                    "",
                                                    titleText: Text(
                                                      "Added to Cart",
                                                      style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                                    messageText: Text(
                                                      "${service.name} added successfully.",
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 13.sp,
                                                      ),
                                                    ),
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor:
                                                        Colors.white,
                                                    colorText: Colors.black,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            16),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 20),
                                                    borderRadius: 16,
                                                    duration: const Duration(
                                                        seconds: 3),
                                                    isDismissible: true,
                                                    dismissDirection:
                                                        DismissDirection
                                                            .horizontal,
                                                    forwardAnimationCurve:
                                                        Curves.easeOutBack,
                                                    leftBarIndicatorColor:
                                                        _themeOrange,
                                                    boxShadows: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 20,
                                                        offset: const Offset(
                                                            0, 10),
                                                        spreadRadius: 2,
                                                      )
                                                    ],
                                                    icon: Container(
                                                      margin: const EdgeInsets
                                                          .only(left: 8),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      decoration: BoxDecoration(
                                                        color: _themeOrange
                                                            .withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(Icons.check,
                                                          color: _themeOrange,
                                                          size: 20),
                                                    ),
                                                    mainButton: TextButton(
                                                      onPressed: () => Get.to(
                                                          () => CartScreen()),
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            _themeOrange
                                                                .withOpacity(
                                                                    0.1),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    16.w,
                                                                vertical: 8.h),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "View Cart",
                                                        style: TextStyle(
                                                          color: _themeOrange,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        18.w * scaleFactor,
                                                    vertical: 7.h * scaleFactor,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        const Color(0xFFFF8F40),
                                                        _themeOrange
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment
                                                          .bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _themeOrange
                                                            .withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    'Add',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          12.sp * scaleFactor,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              )
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
                    );
                  }),
                ),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: 2,
            onItemTapped: (index) => _onItemTapped(index),
          ),
        );
      },
    );
  }

  Widget _buildServiceImage(
      String imgUrl, double height, double scaleFactor) {
    if (imgUrl.isEmpty) {
      return Container(
        color: Colors.grey[100],
        height: height,
        child: Icon(Icons.image_not_supported,
            color: Colors.grey[400], size: 30),
      );
    }

    if (_isSvgUrl(imgUrl)) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: SvgPicture.network(
          imgUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Container(color: Colors.grey[100]),
        ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imgUrl,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[100],
          height: height,
          child: Icon(Icons.image_not_supported,
              color: Colors.grey[400], size: 30),
        ),
      );
    }
  }
}