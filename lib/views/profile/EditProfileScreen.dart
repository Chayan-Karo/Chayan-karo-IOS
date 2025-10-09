import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../../widgets/chayan_header.dart';
import '../../models/customer_models.dart';
import '../../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final Customer? customer;
  const EditProfileScreen({Key? key, this.customer}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _genderController;

  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    super.initState();
    final c = widget.customer ?? _profileController.customer;
    _fullNameController = TextEditingController(text: c?.fullName ?? '');
    _emailController = TextEditingController(text: c?.emailId ?? '');
    _genderController = TextEditingController(text: c?.gender ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: const Color(0xFFFFEDE0),
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Column(
                  children: [
                    ChayanHeader(
                      title: 'Edit Profile',
                      onBack: () => Navigator.pop(context),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40.h * scaleFactor),
                      child: Stack(
                        children: [
                          Container(
                            width: 100.w * scaleFactor,
                            height: 100.w * scaleFactor,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(62 * scaleFactor),
                              image: widget.customer?.imgLink != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.customer!.imgLink!),
                                      fit: BoxFit.cover,
                                    )
                                  : const DecorationImage(
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
                                borderRadius: BorderRadius.circular(9 * scaleFactor),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w * scaleFactor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h * scaleFactor),
                          editableProfileField(
                            label: 'Full Name',
                            controller: _fullNameController,
                            scaleFactor: scaleFactor,
                            hintText: 'Enter your full name',
                          ),
                          editableProfileField(
                            label: 'Email',
                            controller: _emailController,
                            scaleFactor: scaleFactor,
                            keyboardType: TextInputType.emailAddress,
                            hintText: 'Enter your email address',
                          ),
                          readOnlyProfileField(
                            label: 'Mobile Number',
                            value: widget.customer?.mobileNo != null ? '+91 ${widget.customer!.mobileNo}' : 'Not provided',
                            scaleFactor: scaleFactor,
                            hasValue: widget.customer?.mobileNo != null,
                          ),
                          genderSelectionField(
                            label: 'Gender',
                            controller: _genderController,
                            scaleFactor: scaleFactor,
                          ),
                          SizedBox(height: 40.h * scaleFactor),
                          SizedBox(
                            width: double.infinity,
                            height: 47.h * scaleFactor,
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE47830),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                'Save changes',
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h * scaleFactor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget editableProfileField({
    required String label,
    required TextEditingController controller,
    required double scaleFactor,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.83,
            )),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(height: 2.h, width: double.infinity, color: const Color(0xFFEBEBEB)),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget readOnlyProfileField({
    required String label,
    required String value,
    required bool hasValue,
    required double scaleFactor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.83,
            )),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? Colors.black : Colors.black.withOpacity(0.4),
                  )),
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(height: 2.h, width: double.infinity, color: const Color(0xFFEBEBEB)),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget genderSelectionField({
    required String label,
    required TextEditingController controller,
    required double scaleFactor,
  }) {
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              height: 1.83,
            )),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _showGenderDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(controller.text.isNotEmpty ? controller.text : 'Select your gender',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: hasValue ? Colors.black : Colors.black.withOpacity(0.4),
                      )),
                ),
              ),
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(height: 2.h, width: double.infinity, color: const Color(0xFFEBEBEB)),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildStatusIcon(bool hasValue) {
    if (hasValue) {
      return SvgPicture.asset(
        'assets/icons/check.svg',
        width: 18.w,
        height: 18.h,
      );
    } else {
      return Container(
        width: 18.w,
        height: 18.h,
        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
        child: Icon(Icons.close, size: 12.sp, color: Colors.white),
      );
    }
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select your gender', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(child: _genderOption('Male')),
                  SizedBox(width: 15.w),
                  Expanded(child: _genderOption('Female')),
                ],
              ),
              SizedBox(height: 15.h),
              Center(child: SizedBox(width: 120.w, child: _genderOption('Other'))),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderOption(String gender) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _genderController.text = gender;
          });
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Text(gender, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
      ),
    );
  }

  void _saveChanges() async {
    if (_fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email address', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (!GetUtils.isEmail(_emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address', snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final profileController = Get.find<ProfileController>();
    bool success = await profileController.updateProfile(
      emailId: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      gender: _genderController.text.trim(),
    );

    if (success) {
      Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
    Get.offAllNamed('/profile'); 
    } else {
      Get.snackbar('Error', profileController.errorMessage, snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
