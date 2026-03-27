import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/chayan_header.dart';
import 'feedback_submitted_screen.dart';
import '../../controllers/feedback_controller.dart'; 

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackController _feedbackController = Get.put(FeedbackController());

  // State
  int serviceRating = 0;
  final TextEditingController _serviceCommentController = TextEditingController();
  int providerRating = 0;
  final TextEditingController _providerCommentController = TextEditingController();

  // Arguments
  late String spId;
  late String bookingId;
  // Removed serviceId variable as it is no longer needed
  late String serviceName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    spId = args['spId'] ?? '';
    bookingId = args['bookingId'] ?? '';
    // Removed serviceId extraction
    serviceName = args['serviceName'] ?? 'Service';
  }

  @override
  void dispose() {
    _serviceCommentController.dispose();
    _providerCommentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: Colors.white,
        // Optional: Wrap with GestureDetector to hide keyboard on tap outside
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChayanHeader(
                    title: 'Feedback',
                    onBack: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 24.h * scaleFactor),

                  // ==========================================
                  // 1. SERVICE SECTION
                  // ==========================================
                  
                  // Clean Service Name Display
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w * scaleFactor),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 24.h * scaleFactor, horizontal: 16.w * scaleFactor),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA), // Very subtle grey
                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            serviceName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.sp * scaleFactor,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF161616),
                              letterSpacing: -0.5,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          SizedBox(height: 8.h * scaleFactor),
                          Text(
                            'Booking ID: ${bookingId.length > 8 ? bookingId.substring(0, 8) : bookingId}',
                            style: TextStyle(
                              fontSize: 12.sp * scaleFactor,
                              color: Colors.grey[500],
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h * scaleFactor),

                  // Service Rating Question
                  Center(
                    child: Text(
                      'How was the service?',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h * scaleFactor),

                  // Service Stars
                  _buildStarRating(
                    rating: serviceRating,
                    onRate: (val) => setState(() => serviceRating = val),
                    scaleFactor: scaleFactor,
                  ),

                  // Service Comment
                  _buildCommentBox(
                    controller: _serviceCommentController,
                    hint: 'Share your experience with the service...',
                    scaleFactor: scaleFactor,
                  ),

                  SizedBox(height: 32.h * scaleFactor),
                  
                  // Professional Divider
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w * scaleFactor),
                    child: Divider(thickness: 1, color: Colors.grey[200]),
                  ),
                  
                  SizedBox(height: 32.h * scaleFactor),

                  // ==========================================
                  // 2. PROVIDER SECTION
                  // ==========================================
                  
                  // Section Header
                  Center(
                    child: Text(
                      'SERVICE PROVIDER',
                      style: TextStyle(
                        fontSize: 12.sp * scaleFactor,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[400],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 12.h * scaleFactor),

                  // Provider Rating Question
                  Center(
                    child: Text(
                      'How was the provider\'s behavior?',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h * scaleFactor),

                  // Provider Stars
                  _buildStarRating(
                    rating: providerRating,
                    onRate: (val) => setState(() => providerRating = val),
                    scaleFactor: scaleFactor,
                  ),

                  // Provider Comment
                  _buildCommentBox(
                    controller: _providerCommentController,
                    hint: 'Any feedback about the provider?',
                    scaleFactor: scaleFactor,
                  ),

                  SizedBox(height: 40.h * scaleFactor),

                  // ==========================================
                  // 3. SUBMIT BUTTON
                  // ==========================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w * scaleFactor),
                    child: Obx(() => SizedBox(
                      width: double.infinity,
                      height: 54.h * scaleFactor,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (serviceRating > 0 && providerRating > 0)
                                ? const Color(0xFFE47830)
                                : const Color(0xFFE0E0E0),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scaleFactor),
                            ),
                          ),
                          onPressed: (serviceRating > 0 && providerRating > 0 && !_feedbackController.isLoading.value)
                              ? _submitFeedback
                              : null,
                          child: _feedbackController.isLoading.value 
                            ? SizedBox(
                                width: 24.w * scaleFactor,
                                height: 24.w * scaleFactor,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                              'Submit Feedback',
                              style: TextStyle(
                                fontSize: 16.sp * scaleFactor,
                                color: (serviceRating > 0 && providerRating > 0) 
                                  ? Colors.white 
                                  : const Color(0xFF9E9E9E),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'SF Pro Display',
                                letterSpacing: 0.5,
                              ),
                            ),
                        ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStarRating({required int rating, required Function(int) onRate, required double scaleFactor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
             // Add a subtle vibration or sound here if needed
             onRate(index + 1);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w * scaleFactor),
            child: AnimatedScale(
              scale: rating > index ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                rating > index ? Icons.star_rounded : Icons.star_outline_rounded,
                color: rating > index ? const Color(0xFFFFC107) : const Color(0xFFD0D0D0),
                size: 40 * scaleFactor,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentBox({required TextEditingController controller, required String hint, required double scaleFactor}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w * scaleFactor, vertical: 16.h * scaleFactor),
      child: TextFormField(
        controller: controller,
        maxLines: 3,
        style: TextStyle(fontSize: 14.sp * scaleFactor, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14.sp * scaleFactor, 
            color: Colors.grey[400],
            fontWeight: FontWeight.w400
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor, vertical: 16.h * scaleFactor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scaleFactor),
            borderSide: const BorderSide(color: Color(0xFFE47830), width: 1.5),
          ),
        ),
      ),
    );
  }

  void _submitFeedback() async {
    bool success = await _feedbackController.submitAllFeedback(
      spId: spId,
      bookingId: bookingId,
      // Removed serviceId: serviceId,
      serviceRating: serviceRating,
      serviceComment: _serviceCommentController.text.trim(),
      providerRating: providerRating,
      providerComment: _providerCommentController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FeedbackSubmittedScreen()),
      );
    }
  }
}