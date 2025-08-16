import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/chayan_header.dart';
import 'feedback_submitted_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int selectedRating = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ChayanHeader(
                    title: 'Feedback',
                    onBackTap: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 16.h * scaleFactor),

                  // Service Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: Container(
                      height: 132.h * scaleFactor,
                      padding: EdgeInsets.all(12.r * scaleFactor),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF3F3F3), width: 2.w * scaleFactor),
                        borderRadius: BorderRadius.circular(20 * scaleFactor),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14 * scaleFactor),
                            child: Image.asset(
                              'assets/cleanup.webp',
                              width: 100.w * scaleFactor,
                              height: 100.h * scaleFactor,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 16.w * scaleFactor),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Diamond Facial',
                                style: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                  color: const Color(0xFF161616),
                                ),
                              ),
                              SizedBox(height: 8.h * scaleFactor),
                              _dotWithText('2 hrs', scaleFactor),
                              SizedBox(height: 4.h * scaleFactor),
                              _dotWithText('Includes dummy info', scaleFactor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h * scaleFactor),

                  // Question
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w * scaleFactor),
                    child: Text(
                      'How would you rate the experience\n          and service ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                        color: const Color(0xFF161616),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h * scaleFactor),

                  // Star Ratings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: selectedRating > index
                              ? const Color(0xFFE47830)
                              : const Color(0xFFCCCCCC),
                          size: 32 * scaleFactor,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),

                  if (selectedRating > 0)
                    Text(
                      '$selectedRating - ${_getRatingLabel(selectedRating)}',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF161616),
                        fontFamily: 'Inter',
                      ),
                    ),

                  SizedBox(height: 24.h * scaleFactor),

                  // Comment Box
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: TextFormField(
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Tell us on how we can improve',
                        hintStyle: TextStyle(
                          fontSize: 14.sp * scaleFactor,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9F9F9),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                          borderSide: const BorderSide(color: Color(0xFFFFC76B)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 * scaleFactor),
                          borderSide: const BorderSide(color: Color(0xFFE47830)),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h * scaleFactor),

                  // Add Photos Title
                  Padding(
                    padding: EdgeInsets.only(left: 25.r * scaleFactor, bottom: 8.r * scaleFactor),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Add Photos',
                        style: TextStyle(
                          fontSize: 20.sp * scaleFactor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Add Photo Blocks
                  Padding(
                    padding: EdgeInsets.only(left: 25.r * scaleFactor),
                    child: Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: EdgeInsets.only(right: 10.r * scaleFactor),
                          width: 80.w * scaleFactor,
                          height: 80.h * scaleFactor,
                          decoration: BoxDecoration(
                            color: index == 0 ? const Color(0xFFD9D9D9) : Colors.white,
                            border: Border.all(
                              color: index == 0
                                  ? Colors.transparent
                                  : Colors.black.withOpacity(0.6),
                            ),
                            borderRadius: BorderRadius.circular(20 * scaleFactor),
                          ),
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 36.sp * scaleFactor,
                                fontWeight: FontWeight.w500,
                                color: Colors.black.withOpacity(0.7),
                                shadows: index == 0
                                    ? const [
                                        Shadow(
                                          offset: Offset(0, 1),
                                          blurRadius: 4,
                                          color: Color(0xFFE47830),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 32.h * scaleFactor),

                  // Submit Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedRating > 0
                            ? const Color(0xFFE47830)
                            : const Color(0xFFD9D9D9),
                        minimumSize: Size(double.infinity, 48.h * scaleFactor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10 * scaleFactor),
                        ),
                      ),
                      onPressed: selectedRating > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const FeedbackSubmittedScreen()),
                              );
                            }
                          : null,
                      child: Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16.sp * scaleFactor,
                          color: Colors.white,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h * scaleFactor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dotWithText(String text, double scaleFactor) {
    return Row(
      children: [
        Container(
          width: 4.w * scaleFactor,
          height: 4.h * scaleFactor,
          decoration: const BoxDecoration(
            color: Color(0xFF757575),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w * scaleFactor),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp * scaleFactor,
            color: const Color(0xFF757575),
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
