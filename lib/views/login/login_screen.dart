import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTabletDevice = constraints.maxWidth > 600;
        final double scaleFactor = isTabletDevice ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                // Top Section with logo (unchanged)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF2F4FF),
                  padding: EdgeInsets.only(
                    top: 64.h * scaleFactor,
                    bottom: 16.h * scaleFactor,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 340.w * scaleFactor,
                      height: 240.h * scaleFactor,
                      child: SvgPicture.asset(
                        "assets/icons/logo.svg",
                        fit: BoxFit.contain,
                        width: 340.w * scaleFactor,
                        height: 240.h * scaleFactor,
                      ),
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  height: 16.h * scaleFactor,
                  color: const Color(0xFFF2F4FF),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 120.h * scaleFactor),
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w * scaleFactor,
                            vertical: 16.h * scaleFactor,
                          ),
                          children: [
                            TextField(
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              style: TextStyle(
                                fontFamily: 'SFProRegular',
                                fontSize: 16.sp * scaleFactor,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "Enter your 10-digit number",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                    left: 12.w * scaleFactor,
                                    right: 8.w * scaleFactor,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "+91",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'SFProSemibold',
                                          fontSize: 16.sp * scaleFactor,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 8.w * scaleFactor),
                                      Container(
                                        width: 1.w * scaleFactor,
                                        height: 28.h * scaleFactor,
                                        color: const Color(0xFF79747E),
                                      ),
                                    ],
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w * scaleFactor,
                                  vertical: 14.h * scaleFactor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r * scaleFactor),
                                  borderSide: const BorderSide(color: Color(0xFF79747E)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r * scaleFactor),
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF6F00),
                                    width: 2.w * scaleFactor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h * scaleFactor),
                            
                            // Error message display
                            Obx(() => controller.errorMessage.isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.only(bottom: 8.h * scaleFactor),
                                    padding: EdgeInsets.all(12.w * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8.r * scaleFactor),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 20.sp * scaleFactor,
                                        ),
                                        SizedBox(width: 8.w * scaleFactor),
                                        Expanded(
                                          child: Text(
                                            controller.errorMessage,
                                            style: TextStyle(
                                              fontSize: 12.sp * scaleFactor,
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
                            
                            Text(
                              "An OTP will be sent on given phone number for verification.\nStandard message and data rates apply.",
                              style: TextStyle(
                                fontSize: 12.sp * scaleFactor,
                                fontFamily: 'Inter',
                                height: 1.5,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom fixed section (unchanged)
                      Positioned(
                        bottom: 0.h,
                        left: 0.w,
                        right: 0.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w * scaleFactor,
                            vertical: 16.h * scaleFactor,
                          ),
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() => SizedBox(
                                width: double.infinity,
                                height: 55.h * scaleFactor,
                                child: ElevatedButton(
                                  onPressed: controller.isButtonEnabled && !controller.isLoading
                                      ? controller.sendOTP
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: controller.isButtonEnabled
                                        ? const Color(0xFFFF6F00)
                                        : const Color(0xFFE6EAFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r * scaleFactor),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading
                                      ? SizedBox(
                                          width: 20.w * scaleFactor,
                                          height: 20.h * scaleFactor,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          "Get Verification OTP",
                                          style: TextStyle(
                                            fontSize: 16.sp * scaleFactor,
                                            fontFamily: 'SFProSemibold',
                                            color: controller.isButtonEnabled
                                                ? Colors.white
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                ),
                              )),
                              SizedBox(height: 12.h * scaleFactor),
                              Text(
                                "By Continuing, You agree to our T&C and Privacy Policy",
                                style: TextStyle(
                                  fontSize: 10.sp * scaleFactor,
                                  fontFamily: 'SFProRegular',
                                  color: Colors.black.withOpacity(0.8),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
