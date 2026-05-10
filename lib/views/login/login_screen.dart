import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import 'widgets/legal_modal.dart';
import 'package:flutter/gestures.dart';
import 'widgets/legal_content.dart';
import '../../utils/test_extensions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _showPrivacyPolicy() {
  Get.bottomSheet(
    LegalModal(
      title: LegalContent.privacyPolicyTitle,
      lastUpdated: LegalContent.privacyPolicyUpdate,
      content: LegalContent.privacyPolicyText,
    ),
    isScrollControlled: true,
  );
}

void _showTermsConditions() {
  Get.bottomSheet(
    LegalModal(
      title: LegalContent.termsTitle,
      lastUpdated: LegalContent.termsUpdate,
      content: LegalContent.termsText,
    ),
    isScrollControlled: true,
  );
}
 @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack( // Using Stack to prevent layout shifts
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isTablet = constraints.maxWidth > 600;
                final double sf = isTablet ? constraints.maxWidth / 411 : 1;

                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16.w * sf,
                    right: 16.w * sf,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
  const StaticLoginLogo(),

                      SizedBox(height: 20.h),

                      /// ---------------- PHONE FIELD ----------------
                      TextField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: TextStyle(
                          fontFamily: 'SFProRegular',
                          fontSize: 16.sp * sf,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter your 10-digit number",
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 12.w),
                              Text(
                                "+91",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SFProSemibold',
                                  fontSize: 16.sp * sf,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                width: 1,
                                height: 26.h,
                                color: const Color(0xFF79747E),
                              ),
                              SizedBox(width: 8.w),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF79747E)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF6F00),
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                        ),
                      ).withId('login_phone_input'),

                      SizedBox(height: 6.h),

                      /// ---------------- ERROR BOX ----------------
                      Obx(
                        () => controller.errorMessage.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 18.sp),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        controller.errorMessage,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontFamily: 'Inter',
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      SizedBox(height: 10.h),

                      Text(
                        "An OTP will be sent on given phone number for verification.\nStandard message and data rates apply.",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Inter',
                          color: const Color(0xFF757575),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 120.h), // Enough space for scroll
                    ],
                  ),
                );
              },
            ),

            /// 🚀 NEW: SKIP BUTTON (Floating at Top Right)
            Positioned(
              top: 10.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () => controller.skipLogin(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: const Color(0xFFFF6F00),
                          fontFamily: 'SFProSemibold',
                          fontSize: 14.sp,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18.sp, color: const Color(0xFFFF6F00)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      /// ---------------- FIXED SAFE BOTTOM BUTTON ----------------
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            16.w,
            14.h,
            16.w,
            14.h +
                (MediaQuery.of(context).viewInsets.bottom == 0
                    ? MediaQuery.of(context).viewPadding.bottom
                    : 0),
          ),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: controller.isButtonEnabled &&
                            !controller.isLoading
                        ? controller.sendOTP
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isButtonEnabled
                          ? const Color(0xFFFF6F00)
                          : const Color(0xFFE6EAFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Get Verification OTP",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: 'SFProSemibold',
                              color: controller.isButtonEnabled
                                  ? Colors.white
                                  : const Color(0xFF757575),
                            ),
                          ),
                  ).withId('login_get_otp_btn'),
                ),
              ),

              SizedBox(height: 6.h),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "By Continuing, You agree to our ",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'SFProRegular',
                    color: Colors.black.withOpacity(0.8),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: "T&C",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showTermsConditions();
                        },
                    ),
                    const TextSpan(
                      text: " and ",
                    ),
                    TextSpan(
                      text: "Privacy Policy",
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showPrivacyPolicy();
                        },
                    ),
                  ],
                ),
              ).withId('login_legal_text_block'),
            ],
          ),
        ),
      ),
    );
  }
}
class StaticLoginLogo extends StatelessWidget {
  const StaticLoginLogo({super.key}); // const constructor is the secret sauce

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Fixed height prevents the logo from jumping when the keyboard appears
      height: 280.h, 
      //color: const Color(0xFFF2F4FF),
      color: Colors.white,

      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 220.h, // Scaled constraint
          ),
          child: SvgPicture.asset(
            "assets/icons/logo.svg",
            width: 280.w,
            fit: BoxFit.contain,
            // Pre-parsing prevents the "flicker" on load
            placeholderBuilder: (context) => SizedBox(height: 220.h, width: 280.w),
          ),
        ),
      ),
    );
  }
}