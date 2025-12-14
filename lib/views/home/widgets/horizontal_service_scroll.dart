import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../controllers/category_controller.dart';
import '../../../models/category_models.dart';
import '../../../models/service_models.dart';
import '../../../services/universal_service_screen.dart';
import '../../../data/repository/service_repository.dart';
// Import the screen to navigate to
import '../../all_most_used_services/all_most_used_services_screen.dart';

class HorizontalServiceScroll extends StatefulWidget {
  const HorizontalServiceScroll({super.key});

  @override
  State<HorizontalServiceScroll> createState() => _HorizontalServiceScrollState();
}

class _HorizontalServiceScrollState extends State<HorizontalServiceScroll> {
  final RxList<Service> _combinedServices = <Service>[].obs;
  final RxBool _isLoading = true.obs;
  bool _hasTriggeredFetch = false;

  @override
  void initState() {
    super.initState();
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
          print("⚠️ Error fetching sub-category $id: $e");
        }
      }
      final uniqueServices = {for (var s in allResults) s.id: s}.values.toList();
      _combinedServices.assignAll(uniqueServices);
    } catch (e) {
      print("❌ Critical error fetching services: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ UPDATED: Navigate to AllMostUsedServicesScreen on tap
  void _navigateToService(Service service) {
    Get.to(() => const AllMostUsedServicesScreen());
  }

  bool _isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryController = Get.find<CategoryController>();

      if (!_hasTriggeredFetch && categoryController.filteredCategories.isNotEmpty) {
        final Category? targetCategory = categoryController.filteredCategories
            .firstWhereOrNull((cat) {
              final name = cat.categoryName.toLowerCase();
              return (name.contains('women') || name.contains('female')) && 
                     (name.contains('spa') || name.contains('spa'));
            });

        if (targetCategory != null && targetCategory.serviceCategory.isNotEmpty) {
          _hasTriggeredFetch = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final List<String> allSubCatIds = targetCategory.serviceCategory
                .map((e) => e.serviceCategoryId)
                .toList();
            _fetchAllSubCategoryServices(allSubCatIds);
          });
        }
      }

      if (_isLoading.value) {
        return _buildShimmerLoading(context);
      }

      if (_combinedServices.isEmpty) {
        return const SizedBox.shrink();
      }

      final services = _combinedServices;

      return LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth >= 600;
          double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

          double imageWidth = 117.w * scaleFactor;
          double imageHeight = 116.h * scaleFactor;
          double titleFontSize = 12.sp * scaleFactor;
          double priceFontSize = 12.sp * scaleFactor;
          double oldPriceFontSize = 10.sp * scaleFactor;
          double ratingFontSize = 10.sp * scaleFactor;
          double starSize = 14.h * scaleFactor;

          double contentHeight = imageHeight +
              8.h * scaleFactor +
              (titleFontSize * 1.33 * 2) +
              4.h * scaleFactor +
              (ratingFontSize * 1.2) +
              4.h * scaleFactor +
              (priceFontSize * 1.2) +
              5.h * scaleFactor;

          return SizedBox(
            height: contentHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: services.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w * scaleFactor),
              itemBuilder: (context, index) {
                final service = services[index];

                double originalPriceVal;
                if (service.discountPercentage > 0) {
                   originalPriceVal = service.price / ((100 - service.discountPercentage) / 100);
                } else {
                   originalPriceVal = service.price * 1.25; 
                }
                final int finalOldPrice = originalPriceVal.toInt();

                return GestureDetector(
                  onTap: () => _navigateToService(service),
                  child: SizedBox(
                    width: imageWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10 * scaleFactor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10 * scaleFactor),
                            child: _buildServiceImage(service.imgLink, scaleFactor),
                          ),
                        ),
                        SizedBox(height: 8.h * scaleFactor),
                        SizedBox(
                          width: imageWidth,
                          child: Text(
                            service.name,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                              color: Colors.black,
                              height: 1.33,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 4.h * scaleFactor),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/star.svg',
                              height: starSize,
                              width: starSize,
                              colorFilter: const ColorFilter.mode(
                              Colors.black,
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
                                "4.8 (2.3k)", 
                                style: TextStyle(
                                  fontSize: ratingFontSize,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF757575),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h * scaleFactor),
                        Row(
                          children: [
                            Text(
                              "₹${service.price.toInt()}",
                              style: TextStyle(
                                fontSize: priceFontSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFA9441),
                              ),
                            ),
                            SizedBox(width: 6.w * scaleFactor),
                            Text(
                              "₹$finalOldPrice",
                              style: TextStyle(
                                fontSize: oldPriceFontSize,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough,
                                color: const Color(0xFFB0B0B0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildServiceImage(String imgUrl, double scaleFactor) {
    if (imgUrl.isEmpty) {
      return Container(color: Colors.grey.shade200);
    }

    if (_isSvgUrl(imgUrl)) {
      return SvgPicture.network(
        imgUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => Container(color: Colors.grey.shade100),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imgUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.cleaning_services,
            color: const Color(0xFFFF6F00),
            size: 32.sp * scaleFactor,
          ),
        ),
      );
    }
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}