import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home/home_screen.dart';
import '../../widgets/chayan_header.dart';

class FeedbackSubmittedScreen extends StatelessWidget {
  const FeedbackSubmittedScreen({super.key});

  // Social links
  final String instagramUrl =
      'https://www.instagram.com/chayankaro?igsh=MWZyOHVhNHV0ZmNrZw==';
  final String facebookUrl =
      'https://www.facebook.com/profile.php?id=61575011660245';
  final String youtubeUrl =
      'https://youtube.com/@chayankaroindia?si=WT0Ga2xEr6hUSsVg';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                ChayanHeader(
                  title: 'Feedback',
                  onBack: () => Navigator.pop(context),
                ),
                SizedBox(height: 40.h * scaleFactor),
                SvgPicture.asset(
                  'assets/icons/feedtick.svg',
                  semanticsLabel: 'Feedback Tick',
                  width: 120.w * scaleFactor,
                  height: 120.h * scaleFactor,
                ),
                SizedBox(height: 32.h * scaleFactor),
                Text(
                  'Feedback Submitted',
                  style: TextStyle(
                    fontSize: 18.sp * scaleFactor,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 12.h * scaleFactor),
                Text(
                  'Thank You! Your Feedback has been\nsubmitted Successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp * scaleFactor,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 24.h * scaleFactor),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE47830)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8 * scaleFactor)),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.h * scaleFactor,
                      vertical: 12.h * scaleFactor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: const Color(0xFFE47830),
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp * scaleFactor,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.r * scaleFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(
                        iconPath: 'assets/icons/insta.svg',
                        onTap: () => _launchUrl(instagramUrl),
                        scaleFactor: scaleFactor,
                      ),
                      SizedBox(width: 24.w * scaleFactor),
                      _buildSocialIcon(
                        iconPath: 'assets/icons/fb.svg',
                        onTap: () => _launchUrl(facebookUrl),
                        scaleFactor: scaleFactor,
                      ),
                      SizedBox(width: 24.w * scaleFactor),
                      _buildSocialIcon(
                        iconPath: 'assets/icons/youtube.svg',
                        onTap: () => _launchUrl(youtubeUrl),
                        scaleFactor: scaleFactor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h * scaleFactor),
                Text(
                  'Our Social Links',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20.h * scaleFactor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialIcon({
    required String iconPath,
    required VoidCallback onTap,
    required double scaleFactor,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        iconPath,
        width: 35.w * scaleFactor,
        height: 35.h * scaleFactor,
      ),
    );
  }
}
