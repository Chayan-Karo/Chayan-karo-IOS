import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../widgets/chayan_header.dart';
import '../../widgets/three_dot_loader.dart'; // <--- IMPORT YOUR LOADER
import '../../models/saathi_models.dart';
import '../../models/saathi_rating_model.dart';
import '../../controllers/saathi_rating_controller.dart';

class ChayanSathiRatingScreen extends StatefulWidget {
  final SaathiItem saathi;

  const ChayanSathiRatingScreen({super.key, required this.saathi});

  @override
  State<ChayanSathiRatingScreen> createState() =>
      _ChayanSathiRatingScreenState();
}

class _ChayanSathiRatingScreenState extends State<ChayanSathiRatingScreen> {
  late final SaathiRatingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SaathiRatingController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchRatings(widget.saathi.id);
    });
  }

  @override
  void dispose() {
    Get.delete<SaathiRatingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Header
          ChayanHeader(
            title: 'Chayan Sathi Ratings',
            onBack: () => Navigator.pop(context),
          ),

          // 2. Provider Summary (Top Section)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                // Profile Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.r),
                  child: Container(
                    width: 70.w,
                    height: 70.w,
                    color: Colors.grey.shade100,
                    child: (widget.saathi.imageUrl != null &&
                            widget.saathi.imageUrl!.isNotEmpty)
                        ? Image.network(
                            widget.saathi.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.person, size: 35.w, color: Colors.grey),
                          )
                        : Icon(Icons.person, size: 35.w, color: Colors.grey),
                  ),
                ),
                SizedBox(width: 16.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.saathi.name,
                        style: TextStyle(
                          fontFamily: 'SFProSemibold',
                          fontSize: 18.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/star.svg',
                            width: 14.w,
                            color: const Color(0xFFFFA500),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${(widget.saathi.rating ?? 0.0).toStringAsFixed(1)} Average Rating",
                            style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${widget.saathi.jobsCompleted ?? 0} Jobs Completed",
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Dynamic Content
          Expanded(
            child: Obx(() {
              // --- LOADING STATE ---
              if (controller.isLoading.value) {
                return Center(
                  child: ThreeDotLoader(
                    size: 14.w,
                    color: const Color(0xFFE47830),
                  ),
                );
              }

              // --- EMPTY STATE (Beautiful Design) ---
              if (controller.reviews.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Container
                        Container(
                          width: 100.w,
                          height: 100.w,
                          padding: EdgeInsets.all(25.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE47830).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/review.svg',
                            color: const Color(0xFFE47830),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        
                        // Title
                        Text(
                          controller.error.value.isNotEmpty
                              ? 'Oops!'
                              : 'No Ratings Yet',
                          style: TextStyle(
                            fontFamily: 'SFProSemibold',
                            fontSize: 20.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        
                        // Subtitle
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                          child: Text(
                            controller.error.value.isNotEmpty
                                ? controller.error.value
                                : "This provider hasn't received any reviews from customers yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'SFPro',
                              fontSize: 15.sp,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // --- LIST DATA STATE ---
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.reviews.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final review = controller.reviews[index];
                  return _buildReviewCard(review);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ProviderRatingItem review) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: (review.customerImage.isNotEmpty &&
                        review.customerImage.startsWith('http'))
                    ? NetworkImage(review.customerImage)
                    : null,
                child: (review.customerImage.isEmpty ||
                        !review.customerImage.startsWith('http'))
                    ? Icon(Icons.person, color: Colors.grey, size: 20.w)
                    : null,
              ),
              SizedBox(width: 12.w),
              // Name and Stars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: TextStyle(
                        fontFamily: 'SFProSemibold',
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFA500),
                            size: 14.w,
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment,
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ]
        ],
      ),
    );
  }
}