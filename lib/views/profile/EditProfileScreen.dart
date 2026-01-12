import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io'; // <--- Required for FileImage
import '../../widgets/chayan_header.dart';
import '../../models/customer_models.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/test_extensions.dart';
import 'package:image_picker/image_picker.dart'; // <--- ADD THIS

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
    // Initialize with passed customer or fallback to controller's current value
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
  ImageProvider _getImageProvider({File? localImage, String? networkUrl}) {
  // 1. Priority: Show Local Image (Instant feedback)
  if (localImage != null) {
    return FileImage(localImage);
  }

  // 2. Secondary: Show Network Image with Cache Busting
  if (networkUrl != null && networkUrl.isNotEmpty) {
    // Append timestamp to force refresh
    return NetworkImage('$networkUrl?v=${_profileController.imageVersion.value}');
  }

  // 3. Fallback: Default Placeholder
  return const AssetImage('assets/userprofile.webp');
}
// NEW: Bottom Sheet to choose Camera or Gallery (Fixes BUG-022/023)
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFE47830)),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Calls controller with Gallery source
                  _profileController.pickAndUploadImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE47830)),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Calls controller with Camera source
                  _profileController.pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
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
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    const ChayanHeader(
                      title: 'Edit Profile',
                    ),
                    
                    // UPDATED: Profile Image Section with Upload Logic
                    Container(
                      margin: EdgeInsets.only(top: 40.h * scaleFactor),
                      child: Obx(() {
                        // Prioritize live data from controller to show updates immediately
                        final currentCustomer = _profileController.customer ?? widget.customer;
                        final isUploading = _profileController.isUploading;
                        
                        return Stack(
                          children: [
                            // 1. Profile Image Circle
                            Container(
                              width: 100.w * scaleFactor,
                              height: 100.w * scaleFactor,
                             decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(62 * scaleFactor),
  color: Colors.grey[200],
  image: DecorationImage(
    fit: BoxFit.cover,
    
    // --- UPDATED LOGIC ---
    // Uses the helper to check Local File -> Network URL -> Asset
    image: _getImageProvider(
      localImage: _profileController.localImage.value,
      networkUrl: currentCustomer?.imageUrl,
    ),
    // ---------------------
  ),
),
                            ),
                            
                            // 2. Edit/Upload Icon Button
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: isUploading 
                                    ? null 
                                 : () => _showImageSourceOptions(), // <--- NEW CODE
                                child: Container(
                                  width: 32.w * scaleFactor,
                                  height: 32.w * scaleFactor,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE47830),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isUploading
                                        ? SizedBox(
                                            width: 14.w * scaleFactor,
                                            height: 14.w * scaleFactor,
                                            child: const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt, // Changed to camera icon for better context
                                            color: Colors.white,
                                            size: 16.sp * scaleFactor,
                                          ),
                                  ),
                                ),
                              ),
                            ).withId('edit_profile_image_btn'),
                          ],
                        );
                      }),
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
                            testId: 'edit_profile_name_input', // <--- Added ID
                            hintText: 'Enter your full name',
                            // ADD THIS: Allows only letters (a-z, A-Z) and spaces
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            ],
                          ),
                          editableProfileField(
                            label: 'Email',
                            controller: _emailController,
                            scaleFactor: scaleFactor,
                            keyboardType: TextInputType.emailAddress,
                            testId: 'edit_profile_email_input', // <--- Added ID
                            hintText: 'Enter your email address',
                          ),
                          readOnlyProfileField(
                            label: 'Mobile Number',
                            value: widget.customer?.mobileNo != null
                                ? '+91 ${widget.customer!.mobileNo}'
                                : 'Not provided',
                            scaleFactor: scaleFactor,
                            hasValue: widget.customer?.mobileNo != null,
                          ),
                          genderSelectionField(
                            label: 'Gender',
                            controller: _genderController,
                            scaleFactor: scaleFactor,
                            testId: 'edit_profile_gender_select', // <--- Added ID
                          ),
                          SizedBox(height: 40.h * scaleFactor),
                          SizedBox(
                            width: double.infinity,
                            height: 47.h * scaleFactor,
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE47830),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                            ).withId('edit_profile_save_btn'),
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
    required String testId, // <--- 1. ADD THIS
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters, // <--- Added this parameter
  }) {
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.83,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters, // <--- Pass it here
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
              ).withId(testId),
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 2.h,
          width: double.infinity,
          color: const Color(0xFFEBEBEB),
        ),
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
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.83,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: hasValue
                      ? Colors.black
                      : Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 2.h,
          width: double.infinity,
          color: const Color(0xFFEBEBEB),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget genderSelectionField({
    required String label,
    required TextEditingController controller,
    required double scaleFactor,
    required String testId, // <--- 1. ADD THIS
  }) {
    final hasValue = controller.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.83,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _showGenderDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'Select your gender',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: hasValue
                          ? Colors.black
                          : Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),
               ).withId(testId), // <--- 2. USE IT HERE
            ),
            _buildStatusIcon(hasValue),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          height: 2.h,
          width: double.infinity,
          color: const Color(0xFFEBEBEB),
        ),
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
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close,
          size: 12.sp,
          color: Colors.white,
        ),
      );
    }
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select your gender',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(child: _genderOption('Male').withId('gender_option_male')),
                  SizedBox(width: 15.w),
                  Expanded(child: _genderOption('Female').withId('gender_option_female')),
                ],
              ),
              SizedBox(height: 15.h),
              Center(
                child: SizedBox(
                  width: 120.w,
                  child: _genderOption('Other').withId('gender_option_other'),
                ),
              ),
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
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        child: Text(
          gender,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _saveChanges() async {
    final name = _fullNameController.text.trim();

    // 1. Validation: Name Validation
    if (name.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your full name',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    // Check if name is MORE than 3 characters (must be 4 or more)
    if (name.length <= 3) {
      Get.snackbar(
        'Error',
        'Name must be more than 3 characters',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    // Double check for special characters (Safety check)
    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(name)) {
      Get.snackbar(
        'Error',
        'Special characters are not allowed in name',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    // 2. Validation: Gender
    if (_genderController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please select your gender',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

// 3. Validation: Email (Optional)
    final rawEmail = _emailController.text.trim();

    if (rawEmail.isNotEmpty) {
      // STRICT REGEX: Enforces starting with a Letter or Number (^[a-zA-Z0-9])
      // This explicitly blocks emails starting with dots (.) or underscores (_)
      final emailRegExp = RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

      if (!emailRegExp.hasMatch(rawEmail)) {
        Get.snackbar(
          'Error',
          'Please enter a valid email address',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
        return;
      }
    }

    // Prepare nullable email
    final String? emailToSend = rawEmail.isEmpty ? null : rawEmail;

    final success = await _profileController.updateProfile(
      emailId: emailToSend,
      fullName: name, // Use the trimmed name
      gender: _genderController.text.trim(),
    );

    if (success) {
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/profile');
    } else {
      Get.snackbar(
        'Error',
        _profileController.errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }
}