import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../widgets/app_snackbar.dart';
import '../../../widgets/app_network_image.dart';
import '../../../models/service_models.dart';
import '../../booking/Summaryscreen.dart';

class CategorySelectionSheet extends StatelessWidget {
  final Map<String, List<CartItem>> groupedItems;

  const CategorySelectionSheet({super.key, required this.groupedItems});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scale = constraints.maxWidth > 600 ? constraints.maxWidth / 411 : 1.0;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w * scale, vertical: 20.h * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r * scale)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Select Category to Checkout',
                    style: TextStyle(
                      fontSize: 18.sp * scale,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              'You can only book services from one category at a time.',
              style: TextStyle(
                fontSize: 13.sp * scale,
                color: Colors.grey[600],
                fontFamily: 'SF Pro',
              ),
            ),
            SizedBox(height: 20.h * scale),

            // Category List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: groupedItems.entries.map((entry) {
                    final String sourceTitle = entry.key;
                    final List<CartItem> items = entry.value;
                    final double total = items.fold(0.0, (sum, item) => sum + item.totalPrice);
                    final String firstItemImage = items.isNotEmpty ? items.first.image : '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (total < 99) {
                          AppSnackbar.showWarning('Minimum order ₹99 required for $sourceTitle');
                        } else {
                       _navigateToSummary(context, items, sourceTitle);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h * scale),
                        padding: EdgeInsets.all(12.r * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r * scale),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r * scale),
                              child: AppNetworkImage(
                                imageUrl: firstItemImage,
                                width: 50.w * scale,
                                height: 50.h * scale,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12.w * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sourceTitle,
                                    style: TextStyle(
                                      fontSize: 15.sp * scale,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'SF Pro',
                                    ),
                                  ),
                                  Text(
                                    '${items.length} Services • ₹${total.toInt()}',
                                    style: TextStyle(
                                      fontSize: 12.sp * scale,
                                      color: const Color(0xFFE47830),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp * scale, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10.h),
          ],
        ),
      );
    });
  }

  void _navigateToSummary(BuildContext context, List<CartItem> items,  String sourceTitle) {
    final List<String> selectedServiceIds = items.map((item) => item.id).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(
          currentPageSelectedServices: selectedServiceIds,
          initialAddress: 'Default Address',
          initialTimeSlot: 'Select time slot',
          initialSaathi: null,
          selectedSourceTitle: sourceTitle, // NEW

        ),
      ),
    );
  }
}