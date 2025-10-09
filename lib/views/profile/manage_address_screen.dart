import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  String locationLabel = 'Home';
  String address = 'Not Available';
  String phone = '+91 0000000000';

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      locationLabel = prefs.getString('location_label') ?? 'Home';
      address = prefs.getString('location_address') ?? 'Not Available';
      phone = prefs.getString('user_phone') ?? '+91 0000000000';
    });
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
              ChayanHeader(
                title: 'Manage Address',
                onBack: () => Navigator.pop(context),
                //onBackTap: () {},
              ),
              SizedBox(height: 16.h * scaleFactor),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Open address adding flow
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add, color: const Color(0xFFE47830), size: 20 * scaleFactor),
                            SizedBox(width: 8.w * scaleFactor),
                            Text(
                              'Add another address',
                              style: TextStyle(
                                color: const Color(0xFFE47830),
                                fontSize: 16.sp * scaleFactor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h * scaleFactor),

                      Container(
                        padding: EdgeInsets.all(16.r * scaleFactor),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFEBEBEB)),
                            bottom: BorderSide(color: Color(0xFFEBEBEB)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/home.svg',
                                  width: 20.w * scaleFactor,
                                  height: 20.h * scaleFactor,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 8.w * scaleFactor),
                                Text(
                                  locationLabel,
                                  style: TextStyle(
                                    fontSize: 16.sp * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showUpdateAddressBottomSheet(scaleFactor);
                                    } else if (value == 'delete') {
                                      _confirmDelete(scaleFactor); // Pass scaleFactor
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    // FIXED: White background for popup menu items
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 14.sp * scaleFactor,
                                          color: Colors.black, // WHITE COLOR
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 14.sp * scaleFactor,
                                          color: Colors.black, // WHITE COLOR
                                        ),
                                      ),
                                    ),
                                  ],
                                  // FIXED: Dark background for the popup menu
                                  color: Colors.white,
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 20 * scaleFactor,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h * scaleFactor),
                            Text(
                              '$address\nPh: $phone',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                height: 1.5,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateAddressBottomSheet(double scaleFactor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.h * scaleFactor)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    SizedBox(height: 8.h * scaleFactor),
                    Container(
                      width: 40.w * scaleFactor,
                      height: 4.h * scaleFactor,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.r * scaleFactor),
                      ),
                    ),
                    SizedBox(height: 16.h * scaleFactor),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Madhapur, Hyderabad',
                                    style: TextStyle(
                                      fontSize: 16.sp * scaleFactor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFE47830)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.r * scaleFactor),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.h * scaleFactor,
                                      vertical: 4.h * scaleFactor,
                                    ),
                                  ),
                                  child: Text(
                                    'Set as Default',
                                    style: TextStyle(
                                      color: const Color(0xFFE47830),
                                      fontSize: 12.sp * scaleFactor,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h * scaleFactor),
                            Text(
                              'Plot no.209, Kavuri Hills, Madhapur, Telangana 500033\nPh: +91234567890',
                              style: TextStyle(
                                fontSize: 13.sp * scaleFactor,
                                color: const Color(0xFF757575),
                                fontFamily: 'Inter',
                              ),
                            ),
                            SizedBox(height: 24.h * scaleFactor),

                            Text(
                              'House/Flat Number *',
                              style: TextStyle(
                                fontSize: 10.sp * scaleFactor,
                                color: const Color(0xFFABABAB),
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                            SizedBox(height: 4.h * scaleFactor),
                            TextFormField(
                              initialValue: 'Plot no.209',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12 * scaleFactor,
                                    vertical: 14 * scaleFactor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r * scaleFactor),
                                ),
                              ),
                            ),
                            SizedBox(height: 16.h * scaleFactor),

                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Landmark (Optional)',
                                labelStyle: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
                                  color: const Color(0xFFABABAB),
                                  fontFamily: 'SF Pro Display',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r * scaleFactor),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h * scaleFactor),

                            Text(
                              'Save as',
                              style: TextStyle(
                                fontSize: 14.sp * scaleFactor,
                                fontFamily: 'SF Pro Display',
                                color: const Color(0xFF757575),
                              ),
                            ),
                            SizedBox(height: 10.h * scaleFactor),

                            Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('Home'),
                                  selected: true,
                                  selectedColor: const Color(0xFFE6EAFF),
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFE47830),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Inter',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Color(0xFFE47830)),
                                    borderRadius: BorderRadius.circular(10.r * scaleFactor),
                                  ),
                                  onSelected: (_) {},
                                ),
                                SizedBox(width: 10.w * scaleFactor),
                                ChoiceChip(
                                  label: const Text('Other'),
                                  selected: false,
                                  labelStyle: const TextStyle(
                                    color: Color(0xFFABABAB),
                                    fontFamily: 'SF Pro Display',
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Color(0xFFE3E3E3)),
                                    borderRadius: BorderRadius.circular(10.r * scaleFactor),
                                  ),
                                  onSelected: (_) {},
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h * scaleFactor),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      top: false,
                      minimum: EdgeInsets.only(
                        left: 16.w * scaleFactor,
                        right: 16.w * scaleFactor,
                        top: 8.h * scaleFactor,
                        bottom: MediaQuery.of(context).viewPadding.bottom > 0
                            ? MediaQuery.of(context).viewPadding.bottom
                            : 8.h * scaleFactor,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 47.h * scaleFactor,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE47830),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r * scaleFactor),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Update address',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              fontSize: 16.sp * scaleFactor,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // FIXED: Updated confirm delete dialog with scaling and white button text
  void _confirmDelete(double scaleFactor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Address',
          style: TextStyle(
            fontSize: 18.sp * scaleFactor,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Inter',
          ),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(
            fontSize: 14.sp * scaleFactor,
            fontFamily: 'Inter',
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp * scaleFactor,
                color: Colors.grey[600],
                fontFamily: 'Inter',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle deletion
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w * scaleFactor,
                vertical: 8.h * scaleFactor,
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white, // WHITE COLOR
                fontSize: 14.sp * scaleFactor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
