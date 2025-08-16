import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/chayan_header.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0xFFFFEDE0),
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Header
                ChayanHeader(
                  title: 'Edit Profile',
                  onBackTap: () {},
                ),

                // Profile image
                Positioned(
                  top: 131.r * scaleFactor,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100.w * scaleFactor,
                          height: 100.w * scaleFactor,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(62 * scaleFactor),
                            image: const DecorationImage(
                              image: AssetImage('assets/userprofile.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 25.w * scaleFactor,
                            height: 25.w * scaleFactor,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE47830),
                              borderRadius:
                                  BorderRadius.circular(9 * scaleFactor),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 15 * scaleFactor,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form
                Positioned.fill(
                  top: 260.r * scaleFactor,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profileField(
                          label: 'Full Name',
                          value: 'Ayush Srivastav (LALA)',
                          scaleFactor: scaleFactor,
                        ),
                        profileField(
                          label: 'Email',
                          value: 'ayushsrivastav047@gmail.com',
                          scaleFactor: scaleFactor,
                        ),
                        profileField(
                          label: 'Mobile Number',
                          value: '+91 7355640235',
                          scaleFactor: scaleFactor,
                        ),
                        profileField(
                          label: 'Gender',
                          value: 'Male',
                          scaleFactor: scaleFactor,
                        ),
                        const Spacer(),
                        SafeArea(
                          minimum:
                              EdgeInsets.only(bottom: 16.r * scaleFactor),
                          child: SizedBox(
                            width: double.infinity,
                            height: 47.h * scaleFactor,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE47830),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scaleFactor),
                                ),
                              ),
                              child: Text(
                                'Save changes',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16.sp * scaleFactor,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h * scaleFactor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget profileField({
    required String label,
    required String value,
    required double scaleFactor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp * scaleFactor,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF757575),
            height: 1.83,
          ),
        ),
        SizedBox(height: 4.h * scaleFactor),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF161616),
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/check.svg',
              width: 18.w * scaleFactor,
              height: 18.h * scaleFactor,
            ),
          ],
        ),
        SizedBox(height: 12.h * scaleFactor),
        Container(
          height: 2.h * scaleFactor,
          width: double.infinity,
          color: const Color(0xFFEBEBEB),
        ),
        SizedBox(height: 20.h * scaleFactor),
      ],
    );
  }
}
