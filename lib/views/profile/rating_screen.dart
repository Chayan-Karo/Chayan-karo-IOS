import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/ReviewSubmittedPopup.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../profile/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/chayan_header.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int selectedRating = 0;

  // URLs
  final String instagramUrl =
      'https://www.instagram.com/chayankaro?igsh=MWZyOHVhNHV0ZmNrZw==';
  final String facebookUrl =
      'https://www.facebook.com/profile.php?id=61575011660245';
  final String youtubeUrl =
      'https://youtube.com/@chayankaroindia?si=WT0Ga2xEr6hUSsVg';

  void _showReviewSubmittedDialog() {
    showDialog(
      context: context,
      builder: (context) => ReviewSubmittedPopup(
        onOkay: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }

  // Helper to launch URLs with Top-SnackBar Error
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        // CHANGED: platformDefault is safer for "Back" navigation
        // when switching between apps (like Facebook) and your app.
        mode: LaunchMode.platformDefault,
      );
    } else {
      if (mounted) {
        // Calculate screen height to force SnackBar to the top
        final double screenHeight = MediaQuery.of(context).size.height;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not open link',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            // Pushes the SnackBar to the Top by adding huge bottom margin
            margin: EdgeInsets.only(
              bottom: screenHeight - 140, 
              left: 20,
              right: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              /// ✅ Reusable Header
              ChayanHeader(
                title: 'Rate Us',
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w * scaleFactor),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h * scaleFactor),
                        Text(
                          'How Did You Liked Chayan Karo?',
                          style: TextStyle(
                            fontSize: 20.sp * scaleFactor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30.h * scaleFactor),
                        Text(
                          'Ratings',
                          style: TextStyle(
                            fontSize: 20.sp * scaleFactor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        SizedBox(height: 20.h * scaleFactor),
                        Container(
                          width: 343.w * scaleFactor,
                          height: 42.h * scaleFactor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40.w * scaleFactor),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE47830),
                            borderRadius:
                                BorderRadius.circular(25 * scaleFactor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: index < selectedRating
                                      ? const Color(0xFFED491F)
                                      : const Color(0xFFD9D9D9),
                                  size: 28 * scaleFactor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedRating = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 30.h * scaleFactor),
                        Text(
                          'Review',
                          style: TextStyle(
                            fontSize: 20.sp * scaleFactor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'SF Pro',
                          ),
                        ),
                        SizedBox(height: 10.h * scaleFactor),
                        Container(
                          width: 343.w * scaleFactor,
                          height: 203.h * scaleFactor,
                          padding: EdgeInsets.all(12.r * scaleFactor),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.46)),
                            borderRadius:
                                BorderRadius.circular(16 * scaleFactor),
                          ),
                          child: const TextField(
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration.collapsed(
                                hintText: 'Write your review here'),
                          ),
                        ),
                        SizedBox(height: 30.h * scaleFactor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              // ✅ CHANGED: Validation Check
                              // If selectedRating is 0, onPressed is null (Disabled)
                              onPressed: selectedRating > 0
                                  ? _showReviewSubmittedDialog
                                  : null, 
                              style: ElevatedButton.styleFrom(
                                // ✅ CHANGED: Visual Feedback
                                // Grey if disabled, Orange if enabled
                                backgroundColor: selectedRating > 0
                                    ? const Color(0xFFE47830)
                                    : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scaleFactor),
                                ),
                                fixedSize: Size(
                                  166 * scaleFactor,
                                  47 * scaleFactor,
                                ),
                              ),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16.sp * scaleFactor,
                                  color: Colors.white,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFFE47830)),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scaleFactor),
                                ),
                                fixedSize: Size(
                                  166 * scaleFactor,
                                  47 * scaleFactor,
                                ),
                              ),
                              child: Text(
                                'No Thanks',
                                style: TextStyle(
                                  fontSize: 16.sp * scaleFactor,
                                  color: Colors.black,
                                  fontFamily: 'SF Pro',
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 40.h * scaleFactor),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => _launchURL(instagramUrl),
                                  child: CircleAvatar(
                                    radius: 17.5 * scaleFactor,
                                    backgroundColor: Colors.white,
                                    child: SvgPicture.asset(
                                      'assets/icons/insta.svg',
                                      width: 35.w * scaleFactor,
                                      height: 35.h * scaleFactor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w * scaleFactor),
                                GestureDetector(
                                  onTap: () => _launchURL(facebookUrl),
                                  child: CircleAvatar(
                                    radius: 21 * scaleFactor,
                                    backgroundColor: Colors.white,
                                    child: SvgPicture.asset(
                                      'assets/icons/fb.svg',
                                      width: 35.w * scaleFactor,
                                      height: 35.h * scaleFactor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w * scaleFactor),
                                GestureDetector(
                                  onTap: () => _launchURL(youtubeUrl),
                                  child: CircleAvatar(
                                    radius: 19 * scaleFactor,
                                    backgroundColor: Colors.white,
                                    child: SvgPicture.asset(
                                      'assets/icons/youtube.svg',
                                      width: 35.w * scaleFactor,
                                      height: 35.h * scaleFactor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h * scaleFactor),
                            Text(
                              'Our Social Links',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'SF Pro',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h * scaleFactor),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}