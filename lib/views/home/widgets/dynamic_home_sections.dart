import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/test_extensions.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/category_models.dart';
import '../../../services/universal_service_screen.dart';

class DynamicHomeSections extends StatelessWidget {
  const DynamicHomeSections({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final categoryController = Get.find<CategoryController>();
      final categories = categoryController.filteredCategories;

      if (categoryController.isLoading && categories.isEmpty) {
        return _buildShimmerState();
      }

      if (categoryController.hasError && categories.isEmpty) {
        return _buildErrorState(categoryController);
      }

      if (categories.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        children: categories
            .where((category) => category.serviceCategory.isNotEmpty)
            .map((category) => RepaintBoundary(
                  child: _buildCategorySection(category),
                ))
            .toList(),
      );
    });
  }

  Widget _buildShimmerState() {
    return const SizedBox.shrink();
  }

  Widget _buildErrorState(CategoryController controller) {
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }

  Widget _buildCategorySection(Category category) {
    if (category.serviceCategory.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth >= 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Container(
          margin: EdgeInsets.only(bottom: 24.h),
          // UPDATED: Removed left padding here.
          // It now relies on the parent (MostUsedServicesWidget) for left alignment.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(category, scaleFactor),
              SizedBox(height: 12.h),
              _buildServiceCards(category, scaleFactor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(Category category, double scaleFactor) {
    final String categorySlug = category.categoryName.toLowerCase().replaceAll(' ', '_');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title starts at 0 relative to parent (which is 12 relative to screen)
        Text(
          category.categoryName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'SF Pro',
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToViewAll(category),
          // Right padding matches the "View all" in MostUsedServicesWidget
          child: Padding(
            padding: EdgeInsets.only(right: 16.0 * scaleFactor),
            child: Text(
              'View all ',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFFA9441),
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ).withId('view_all_$categorySlug'),
        ),
      ],
    );
  }

  Widget _buildServiceCards(Category category, double scaleFactor) {
    double cardWidth = 144.w * scaleFactor;
    double cardHeight = 164.h * scaleFactor;
    double spacing = 12.w * scaleFactor;
    final String categorySlug = category.categoryName.toLowerCase().replaceAll(' ', '_');

    return SizedBox(
      height: cardHeight + (22.h * scaleFactor),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Zero padding allows list to start exactly where the title starts
        padding: EdgeInsets.zero,
        itemCount: category.serviceCategory.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (context, index) {
          final serviceCategory = category.serviceCategory[index];
          return _DynamicServiceCard(
            serviceCategory: serviceCategory,
            parentCategory: category,
            width: cardWidth,
            height: cardHeight,
            scaleFactor: scaleFactor,
          ).withId('service_${categorySlug}_$index');
        },
      ),
    );
  }

  void _navigateToViewAll(Category category) {
    Get.to(() => CategoryServiceScreen(category: category));
  }
}

// -------------------------------- IMAGE OPTIMIZATION BELOW -------------------------------

class _DynamicServiceCard extends StatelessWidget {
  final ServiceSubCategory serviceCategory;
  final Category parentCategory;
  final double width;
  final double height;
  final double scaleFactor;

  const _DynamicServiceCard({
    required this.serviceCategory,
    required this.parentCategory,
    required this.width,
    required this.height,
    required this.scaleFactor,
  });

  bool _isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToService(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10 * scaleFactor),
          border: Border.all(
            color: const Color(0xFFFFD9BE),
            width: 1.w * scaleFactor,
          ),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildServiceImage(),
              _buildServiceLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage() {
    final isSvg = _isSvgUrl(serviceCategory.imgLink);

    return Hero(
      tag: 'service_${serviceCategory.serviceCategoryId}',
      child: isSvg ? _buildSvgImage() : _buildCachedImage(),
    );
  }

  Widget _buildSvgImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.grey.shade200,
        ),
        SvgPicture.network(
          serviceCategory.imgLink,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: serviceCategory.imgLink,
      fit: BoxFit.cover,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 75),
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
      ),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        _getServiceIcon(),
        color: const Color(0xFFFF6F00),
        size: 32.sp * scaleFactor,
      ),
    );
  }

  Widget _buildServiceLabel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 4.h * scaleFactor,
          horizontal: 6.w * scaleFactor,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFD9BE).withOpacity(0.8),
              const Color(0xFFFFD9BE),
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10 * scaleFactor),
            bottomRight: Radius.circular(10 * scaleFactor),
          ),
        ),
        child: Text(
          serviceCategory.serviceCategoryName,
          style: TextStyle(
            fontSize: 10.sp * scaleFactor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  IconData _getServiceIcon() {
    final serviceName = serviceCategory.serviceCategoryName.toLowerCase();

    if (serviceName.contains('clean')) return Icons.cleaning_services;
    if (serviceName.contains('plumb')) return Icons.plumbing;
    if (serviceName.contains('hair') || serviceName.contains('salon')) return Icons.content_cut;
    if (serviceName.contains('spa')) return Icons.spa;
    if (serviceName.contains('repair')) return Icons.build;
    if (serviceName.contains('electric')) return Icons.electrical_services;
    if (serviceName.contains('paint')) return Icons.format_paint;

    return Icons.home_repair_service;
  }

  void _navigateToService() {
    Get.to(() => CategoryServiceScreen(
          category: parentCategory,
          scrollToServiceCategoryId: serviceCategory.serviceCategoryId,
        ));
  }
}