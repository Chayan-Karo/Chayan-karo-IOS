import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../controllers/location_controller.dart';
import '../../models/location_models.dart';

class ManageAddressScreen extends StatefulWidget {
  const ManageAddressScreen({super.key});

  @override
  State<ManageAddressScreen> createState() => _ManageAddressScreenState();
}

class _ManageAddressScreenState extends State<ManageAddressScreen> {
  final LocationController locationController = Get.find<LocationController>();
  String? selectedDefaultId;

  @override
  void initState() {
    super.initState();
    // Fetch after first frame; then align local selection based on data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await locationController.fetchCustomerAddresses();
      _alignSelectedDefaultFromData();
    });
  }

  void _alignSelectedDefaultFromData() {
    final list = locationController.addresses;
    if (list.isEmpty) return;
    final defId = list.firstWhereOrNull((a) => a.isDefault)?.id ?? selectedDefaultId ?? list.first.id;
    if (defId != selectedDefaultId && mounted) {
      // schedule to avoid setState during Obx build phases
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => selectedDefaultId = defId);
      });
    }
  }

  Future<void> _navigateAddOrEditAddress() async {
    final res = await Get.toNamed('/location_popup', arguments: 'manage_address');
    if (res == true) {
      await locationController.fetchCustomerAddresses();
      _alignSelectedDefaultFromData();
    }
  }

  Future<void> _setAsDefault(CustomerAddress address) async {
    await locationController.setDefaultAddressLocal(address.id);
    if (mounted) setState(() => selectedDefaultId = address.id);
    await locationController.fetchCustomerAddresses(silent: true);
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
              ),
              SizedBox(height: 16.h * scaleFactor),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _navigateAddOrEditAddress,
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

                      Expanded(
                        child: Obx(() {
                          if (locationController.isLoadingAddresses.value) {
                            return const Center(
                              child: CircularProgressIndicator(color: Color(0xFFE47830)),
                            );
                          }

                          if (locationController.error.value.isNotEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 48 * scaleFactor, color: Colors.grey),
                                  SizedBox(height: 16.h * scaleFactor),
                                  Text(
                                    'Failed to load addresses',
                                    style: TextStyle(
                                      fontSize: 16.sp * scaleFactor,
                                      color: Colors.grey,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  SizedBox(height: 8.h * scaleFactor),
                                  TextButton(
                                    onPressed: () async {
                                      await locationController.fetchCustomerAddresses();
                                      _alignSelectedDefaultFromData();
                                    },
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: const Color(0xFFE47830),
                                        fontSize: 14.sp * scaleFactor,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final list = locationController.addresses;

                          // Keep local selection aligned once data is ready
                          if (list.isNotEmpty) {
                            final defId = list.firstWhereOrNull((a) => a.isDefault)?.id ?? selectedDefaultId ?? list.first.id;
                            if (defId != selectedDefaultId) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) setState(() => selectedDefaultId = defId);
                              });
                            }
                          }

                          if (list.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off_outlined, size: 48 * scaleFactor, color: Colors.grey),
                                  SizedBox(height: 16.h * scaleFactor),
                                  Text(
                                    'No addresses found',
                                    style: TextStyle(
                                      fontSize: 16.sp * scaleFactor,
                                      color: Colors.grey,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final address = list[index];
                              final isSelectedDefault = address.id == selectedDefaultId;

                              return Container
                              (
                                margin: EdgeInsets.only(bottom: 12.h * scaleFactor),
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
                                          '${address.city}',
                                          style: TextStyle(
                                            fontSize: 16.sp * scaleFactor,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        SizedBox(width: 8.w * scaleFactor),
                                        // Badge driven by local selection to guarantee a single visual default
                                        if (isSelectedDefault)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w * scaleFactor,
                                              vertical: 2.h * scaleFactor,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6EAFF),
                                              borderRadius: BorderRadius.circular(4.r * scaleFactor),
                                              border: Border.all(color: const Color(0xFFE47830)),
                                            ),
                                            child: Text(
                                              'Default',
                                              style: TextStyle(
                                                color: const Color(0xFFE47830),
                                                fontSize: 10.sp * scaleFactor,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        const Spacer(),
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              _showUpdateAddressBottomSheet(scaleFactor, address);
                                            } else if (value == 'delete') {
                                              _confirmDelete(scaleFactor, address.id);
                                            } else if (value == 'make_default') {
                                              await _setAsDefault(address);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 14.sp * scaleFactor,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'make_default',
                                              enabled: !isSelectedDefault,
                                              child: Text(
                                                'Set as Default',
                                                style: TextStyle(
                                                  fontSize: 14.sp * scaleFactor,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  fontSize: 14.sp * scaleFactor,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
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
                                      '${address.addressLine1}, ${address.addressLine2}\n${address.city}, ${address.state} - ${address.postCode}',
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
                              );
                            },
                          );
                        }),
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

 void _showUpdateAddressBottomSheet(double scaleFactor, CustomerAddress address) {
  // Build a neat, trimmed header subtitle from your existing fields
  final addressLine1 = address.addressLine1.trim();
  final addressLine2 = address.addressLine2.trim();
  final cityStatePin = '${address.city}, ${address.state} - ${address.postCode}'.trim();

  final subtitle = <String>[
    if (addressLine1.isNotEmpty) addressLine1,
    if (addressLine2.isNotEmpty) addressLine2,
    cityStatePin,
  ].join(', ').trim();

  // Prefill House/Flat with real address parts; landmark empty for now
  final houseCtrl    = TextEditingController(
    text: [addressLine1, addressLine2].where((s) => s.isNotEmpty).join(', ').trim(),
  );
  final landmarkCtrl = TextEditingController(text: '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        maxChildSize: 0.75,
        minChildSize: 0.45,
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
                                  '${address.city}, ${address.state}',
                                  style: TextStyle(
                                    fontSize: 16.sp * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              if (address.id != selectedDefaultId)
                                TextButton(
                                  onPressed: () async {
                                    await _setAsDefault(address);
                                    if (context.mounted) Navigator.pop(context);
                                  },
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
                            subtitle,
                            style: TextStyle(
                              fontSize: 13.sp * scaleFactor,
                              color: const Color(0xFF757575),
                              fontFamily: 'Inter',
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 24.h * scaleFactor),

                          // House/Flat Number (prefilled from address lines)
                          _OutlinedIconField(
                            scaleFactor: scaleFactor,
                            controller: houseCtrl,
                            hintText: 'House/Flat Number *',
                            icon: Icons.home_outlined,
                          ),
                          SizedBox(height: 16.h * scaleFactor),

                          // Landmark (Optional) – starts blank
                          _OutlinedIconField(
                            scaleFactor: scaleFactor,
                            controller: landmarkCtrl,
                            hintText: 'Landmark (Optional)',
                            icon: Icons.location_on_outlined,
                          ),

                          SizedBox(height: 16.h * scaleFactor),
                          // Phone field removed
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
                        onPressed: () {
                          // Keep as-is for now; no API call here.
                          Navigator.pop(context);
                        },
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

  void _confirmDelete(double scaleFactor, String addressId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
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
            onPressed: () async {
              // 1. Close the dialog
              Navigator.pop(dialogContext);

              // 2. Call delete API
              final success = await locationController.deleteAddress(addressId);

              // 3. Show specific GetX Snackbar
              if (mounted) {
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Address deleted successfully',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[800],
                    margin: EdgeInsets.all(16.w * scaleFactor),
                    borderRadius: 8,
                    duration: const Duration(seconds: 2),
                  );
                  _alignSelectedDefaultFromData();
                } else {
                  Get.snackbar(
                    'Error',
                    locationController.error.value.isNotEmpty
                        ? locationController.error.value
                        : "Failed to delete address",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[800],
                    margin: EdgeInsets.all(16.w * scaleFactor),
                    borderRadius: 8,
                  );
                }
              }
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
                color: Colors.white,
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
class _OutlinedIconField extends StatelessWidget {
  final double scaleFactor;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;

  const _OutlinedIconField({
    required this.scaleFactor,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F4),
        borderRadius: BorderRadius.circular(14 * scaleFactor),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 2 * scaleFactor),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE47830)),
          SizedBox(width: 8 * scaleFactor),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
              ).copyWith(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: const Color(0xFFB9B6B3),
                  fontSize: 15 * scaleFactor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
