import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/three_dot_loader.dart';


// --- App Imports ---
import 'frequently_added_block.dart';
import '../../widgets/chayan_header.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/service_models.dart';
import '../chayan_sathi/chayan_sathi_screen.dart';
import 'PaymentScreen.dart';
import 'showScheduleAddressPopup.dart';
import 'booking_successful_screen.dart';
import '../../controllers/category_controller.dart';
import '../../models/category_models.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../models/booking_models.dart';

// --- NEW IMPORT: Ensure you moved the bottom code to this file ---
import 'merged_booking_modal.dart'; 

// --- UPDATED MODEL: Coupon Model ---
class CouponModel {
  final String id;
  final String title;
  final String description;
  final String code;
  final double value; 
  final bool isPercentage;
  final double minOrderAmount;
  final Color iconColor;

  CouponModel({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.value,
    this.isPercentage = false,
    this.minOrderAmount = 0,
    this.iconColor = Colors.blue,
  });
}

// Updated Mock Data
final List<CouponModel> mockCoupons = [
  CouponModel(
    id: '1',
    title: '20% Off',
    description: 'On orders above ₹500',
    code: 'SAVE20',
    value: 20, 
    isPercentage: true,
    minOrderAmount: 500,
    iconColor: Colors.orange,
  ),
];

class SummaryScreen extends StatefulWidget {
  final List<String>? currentPageSelectedServices;
  final String initialAddress;
  final String initialTimeSlot; 
  final Map<String, dynamic>? initialSaathi;

  const SummaryScreen({
    Key? key,
    this.currentPageSelectedServices,
    this.initialAddress = 'Default Address',
    this.initialTimeSlot = 'Select time slot',
    this.initialSaathi,
  }) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

enum PaymentMethod { afterService, online }

class _SummaryScreenState extends State<SummaryScreen> {
  late String address;
  late String timeSlot;
  late Map<String, dynamic>? saathi;

  String? _locationId;
  String? _addressId;
  List<Service> _frequentlyServices = [];
  bool _frequentlyLoading = false;

  bool _showEditableBlocks = false;

  PaymentMethod _paymentMethod = PaymentMethod.afterService;
  TimeOfDay? _inlineTime;
  bool _isGlobalLoading = false; 

  // 2. UPDATE: Logic to toggle global loader
  Future<void> _updateServiceQty(String itemId, bool increment) async {
    // Safety check: max limit 3
    if (increment && Get.find<CartController>().getQuantity(itemId) >= 3) return;

    setState(() {
      _isGlobalLoading = true; // Turn on global loader
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (increment) {
      Get.find<CartController>().incrementQuantity(itemId);
    } else {
      Get.find<CartController>().decrementQuantity(itemId);
    }

    if (mounted) {
      setState(() {
        _isGlobalLoading = false; // Turn off global loader
      });
    }
  }
  // --- Coupon State ---
  CouponModel? _selectedCoupon;

  late final LocationController _locationController;
  late final BookingController _bookingController;

  @override
  void initState() {
    super.initState();
    address = widget.initialAddress;
    timeSlot = widget.initialTimeSlot;
    saathi = widget.initialSaathi;

    _locationController = Get.find<LocationController>();
    _bookingController = Get.put(BookingController(), permanent: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _locationController.fetchCustomerAddresses();
      _useDefaultAddress();
      await _loadFrequentlyServicesForCurrentCategory();
    });
  }

  void _useDefaultAddress() {
    final list = _locationController.addresses;
    if (list.isEmpty) return;

    final def = list.firstWhereOrNull((a) => a.isDefault) ?? list.first;
    final disp = _formatAddress(
        def.addressLine1 ?? "",
        def.addressLine2 ?? "",
        def.city ?? "",
        def.state ?? "",
        def.postCode ?? "");

    setState(() {
      address = disp;
      _locationId = def.locationId;
      _addressId = def.id;
      // CRITICAL: Start hidden to trigger the "Request Now" -> "Time" -> "Saathi" flow
      _showEditableBlocks = false; 
    });
  }

  void _addServiceIdToCurrentPage(String serviceId) {
    if (widget.currentPageSelectedServices == null) return;
    if (!widget.currentPageSelectedServices!.contains(serviceId)) {
      setState(() {
        widget.currentPageSelectedServices!.add(serviceId);
      });
    }
  }

  String _formatAddress(String l1, String l2, String city, String state, String post) {
    final parts = <String>[l1, if (l2.trim().isNotEmpty) l2, if (city.trim().isNotEmpty) city, if (state.trim().isNotEmpty) state, if (post.trim().isNotEmpty) post];
    return parts.join(', ');
  }

  // --- MERGED MODAL LOGIC ---
  Future<void> _openMergedBookingModal() async {
    // 1. Calculate Constraint from Saathi
    String? nextSlotConstraint;
    if (saathi != null) {
      if (saathi!['availabilityResult'] != null && saathi!['availabilityResult'] is Map) {
         nextSlotConstraint = saathi!['availabilityResult']['nextAvailableSlot'];
      } else if (saathi!['nextAvailableSlot'] != null) {
         nextSlotConstraint = saathi!['nextAvailableSlot'];
      }
    }

    // 2. Prepare Date String (Ensure yyyy-MM-dd format)
    String dateToSend = timeSlot;
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateToSend)) {
       dateToSend = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    // 3. Open Modal (Now Imported from separate file)
    final DateTime? picked = await showMergedBookingModal(
      context,
      initialDateStr: dateToSend,
      initialTime: _inlineTime,
      minTimeConstraint: nextSlotConstraint,
    );

    // 4. Update State
    if (picked != null) {
      setState(() {
        timeSlot = DateFormat('yyyy-MM-dd').format(picked);
        _inlineTime = TimeOfDay.fromDateTime(picked);
      });
    }
  }

  // --- NEW FORMATTER: Combines Date & Time for Header ---
  String _formatFullScheduleDisplay() {
    if (timeSlot == 'Select time slot' || timeSlot.isEmpty) return 'Select time slot';
    
    // Parse Date
    DateTime datePart;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(timeSlot)) {
       datePart = DateFormat('yyyy-MM-dd').parse(timeSlot);
    } else {
       // Fallback logic if needed
       return timeSlot;
    }

    // Determine Relative Day (Today/Tomorrow)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(datePart.year, datePart.month, datePart.day);
    final diff = checkDate.difference(today).inDays;

    String dayPrefix = '';
    if (diff == 0) dayPrefix = 'Today';
    else if (diff == 1) dayPrefix = 'Tomorrow';
    else dayPrefix = DateFormat('EEE').format(datePart); // e.g. Mon, Tue

    // Format Date: "9 Dec"
    final dayMonth = DateFormat('d MMM').format(datePart);

    // Format Time: "10:30 PM"
    String timeString = '';
    if (_inlineTime != null) {
      final dt = DateTime(2022, 1, 1, _inlineTime!.hour, _inlineTime!.minute);
      timeString = DateFormat('h:mm a').format(dt);
    } else {
      timeString = 'Select time';
    }

    // Combine: "Tomorrow 9 Dec 10:30 PM"
    return '$dayPrefix $dayMonth $timeString';
  }

  DateTime _resolveBookingDateTime(String dayToken, TimeOfDay? tod) {
    final now = DateTime.now();
    DateTime date;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dayToken)) {
      date = DateFormat('yyyy-MM-dd').parse(dayToken);
    } else {
      final dd = int.tryParse(dayToken) ?? now.day;
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      final safeDay = dd.clamp(1, lastDay);
      date = DateTime(now.year, now.month, safeDay);
    }
    final time = tod ?? const TimeOfDay(hour: 9, minute: 0);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  List<BookingServiceItem> _mapCartToBookingItems(List<CartItem> items) {
    final cart = Get.find<CartController>();
    final Map<String, _Agg> agg = {};
    for (final it in items) {
      final q = cart.getQuantity(it.id);
      if (q <= 0) continue;

      final key = '${it.categoryId}::${it.id}';
      final pricePerUnit = it.hasDiscount ? it.originalPrice : it.price;
      final discountPerUnit = it.hasDiscount ? it.price : it.price;
      final discountPct = it.hasDiscount && it.originalPrice > 0
          ? (((it.originalPrice - it.price) / it.originalPrice) * 100).round()
          : 0;

      final entry = agg.putIfAbsent(
        key,
        () => _Agg(categoryId: it.categoryId, serviceId: it.id, discountPct: discountPct),
      );
      entry.price += pricePerUnit * q;
      entry.discountPrice += discountPerUnit * q;
    }

    return agg.values
        .map((a) => BookingServiceItem(
              categoryId: a.categoryId,
              serviceId: a.serviceId,
              discountPercentage: a.discountPct,
              price: a.price,
              discountPrice: a.discountPrice,
            ))
        .toList();
  }

  int _estimateTotalDurationMinutes(List<CartItem> items) {
    int total = 0;
    for (final it in items) {
      final q = Get.find<CartController>().getQuantity(it.id);
      final mins = _parseDurationToMinutes(it.duration);
      total += (mins > 0 ? mins : 30) * q;
    }
    return total;
  }

  int _parseDurationToMinutes(String label) {
    if (label.trim().isEmpty) return 0;
    int totalMinutes = 0;
    String lower = label.toLowerCase().trim();

    final hourRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:h|hr|hrs|hour|hours)');
    final hourMatch = hourRegex.firstMatch(lower);
    if (hourMatch != null) {
      double hours = double.tryParse(hourMatch.group(1) ?? '0') ?? 0;
      totalMinutes += (hours * 60).round();
    }

    final minRegex = RegExp(r'(\d+)\s*(?:m|min|mins|minute|minutes)');
    final minMatch = minRegex.firstMatch(lower);
    if (minMatch != null) {
      totalMinutes += int.tryParse(minMatch.group(1) ?? '0') ?? 0;
    }

    if (totalMinutes == 0) {
      final pureNumberRegex = RegExp(r'^(\d+)$');
      final numberMatch = pureNumberRegex.firstMatch(lower);
      if (numberMatch != null) {
         return int.tryParse(numberMatch.group(1)!) ?? 0;
      }
    }
    return totalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scale = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Obx(() {
        final currentPageItems = _getCurrentPageCartItems(cartController);
        final hasCurrentPageItems = currentPageItems.isNotEmpty;
        
        String currentCategoryId = '';
        if (currentPageItems.isNotEmpty) {
          currentCategoryId = currentPageItems.first.categoryId;
        }
        
        final categoryController = Get.find<CategoryController>();
        final category = categoryController.getCategoryById(currentCategoryId);
        final String categoryName = category?.categoryName ?? '';

        final itemTotal = _calculateCurrentPageTotal(currentPageItems);
        final int servicePriceInclusive = itemTotal.round();
        
        // --- Pricing Logic ---
        final int booking     = servicePriceInclusive;
        final int platformFee = (booking * 0.20).round();
        final int perService  = (booking * 0.80).round();
        final int gst         = (platformFee * 0.18).round();
        final int subTotal    = perService + platformFee + gst; 
        
        double discountAmount = 0.0;
        if (_selectedCoupon != null) {
            if (subTotal > _selectedCoupon!.minOrderAmount) {
                if (_selectedCoupon!.isPercentage) {
                    discountAmount = subTotal * (_selectedCoupon!.value / 100);
                } else {
                    discountAmount = _selectedCoupon!.value;
                }
            }
        }
        
        final int totalRaw = (subTotal - discountAmount).toInt();
        final int total = totalRaw > 0 ? totalRaw : 0; 
        // ---------------------
        
        final inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
        
        // --- UPDATED: Use the new single string formatter ---
        final scheduledDisplay = _formatFullScheduleDisplay();

        return Scaffold(
          extendBodyBehindAppBar: true, // ✅ ADD

          backgroundColor: const Color(0xFFFFFEFD),
          body: SafeArea(
            top: false, // ✅ ADD
            child: Stack(
              children: [
                Column(
                  children: [
                    ChayanHeader(
                      title: 'Summary',
                      onBack: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.h * scale, vertical: 8.h * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_showEditableBlocks) ...[
                              _TopDetailsBlock(
                                scale: scale,
                                address: address,
                                timeLabel: scheduledDisplay, // Shows "Tomorrow 9 Dec 10:30 PM"
                                saathi: saathi,
                                onEditAddress: () async {
                                  final newAddress = await showScheduleAddressPopup(context);
                                  if (newAddress != null) {
                                    await _locationController.fetchCustomerAddresses();
                                    final match = _locationController.addresses.firstWhereOrNull((a) {
                                      final existing = _formatAddress(a.addressLine1, a.addressLine2, a.city, a.state, a.postCode).toLowerCase().trim();
                                      return existing == newAddress.toLowerCase().trim();
                                    });
                                    setState(() {
                                      address = newAddress;
                                      _addressId = match?.id ?? _addressId;
                                      _locationId = match?.locationId ?? _locationId;
                                    });
                                  }
                                },
                                onEditTime: () async {
                                  await _openMergedBookingModal();
                                },
                                onEditSaathi: () async {
                                  if ((_locationId ?? '').isEmpty) return;
                                  final items = _getCurrentPageCartItems(Get.find<CartController>());
                                  if (items.isEmpty) return;
                                  final first = items.first;

                                  final DateTime resolvedDate = _resolveBookingDateTime(timeSlot, const TimeOfDay(hour: 0, minute: 0));
                                  final String preciseDateString = DateFormat('yyyy-MM-dd').format(resolvedDate);
                                  final TimeOfDay t = _inlineTime ?? const TimeOfDay(hour: 0, minute: 0);
                                  final String timeString = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                                  final int totalDuration = _estimateTotalDurationMinutes(items);

                                  final selectedSaathi = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChayanSathiScreen(
                                        categoryId: first.categoryId,
                                        serviceId: first.id,
                                        locationId: _locationId!,
                                        addressId: _addressId, 
                                        initialSlot: preciseDateString, 
                                        bookingTime: timeString, 
                                        currentBookingDuration: totalDuration,
                                      ),
                                    ),
                                  );
                                  if (selectedSaathi != null) setState(() => saathi = selectedSaathi);
                                },
                              ),
                              SizedBox(height: 18.h * scale),

                              // --- REMOVED "Request a Service Time" Container HERE ---

                              // Payment selection
                              Container(
                                padding: EdgeInsets.all(16.r * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20 * scale),
                                  boxShadow: [
                                    BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8 * scale, offset: Offset(0, 2 * scale)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp * scale)),
                                    SizedBox(height: 8.h * scale),
                                    Row(
                                      children: [
                                        Radio<PaymentMethod>(
                                          value: PaymentMethod.afterService,
                                          groupValue: _paymentMethod,
                                          onChanged: (v) => setState(() => _paymentMethod = v!),
                                        ),
                                        const Text('Pay after service'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<PaymentMethod>(
                                          value: PaymentMethod.online,
                                          groupValue: _paymentMethod,
                                          onChanged: (v) => setState(() => _paymentMethod = v!),
                                        ),
                                        const Text('Pay Online Now'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h * scale),
                            ],

                            if (hasCurrentPageItems) ...[
                              _SelectedServicesBlock(
                                items: currentPageItems,
                                scale: scale,
                                buildItem: (ci) => _buildServiceItem(ci, scale, !_showEditableBlocks),                              
                                ),
                              SizedBox(height: 20.h * scale),
                            ] else ...[
                              _EmptyServicesBlock(scale: scale),
                              SizedBox(height: 20.h * scale),
                            ],

                 if (!_showEditableBlocks && !_frequentlyLoading && _frequentlyServices.isNotEmpty)
                              FrequentlyAddedBlock(
                                scale: scale,
                                categoryId: currentCategoryId,
                                categoryName: categoryName,
                                services: _frequentlyServices,
                                onAdded: (serviceId) {
                                  _addServiceIdToCurrentPage(serviceId);
                                },
                              )
                            else
                              const SizedBox.shrink(),

                            SizedBox(height: 20.h * scale),

                            if (hasCurrentPageItems) ...[
                              _CouponsRow(
                                scale: scale,
                                selectedCoupon: _selectedCoupon,
                                discountAmount: discountAmount,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => CouponsBottomSheet(
                                      scale: scale,
                                      selectedCoupon: _selectedCoupon,
                                      onApply: (coupon) {
                                        setState(() {
                                          _selectedCoupon = coupon;
                                        });
                                        Get.snackbar(
                                          'Coupon Applied', 
                                          '${coupon.code} applied successfully!',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green[100],
                                          colorText: Colors.green[800],
                                        );
                                      },
                                      onRemove: () {
                                        setState(() {
                                          _selectedCoupon = null;
                                        });
                                        Get.snackbar(
                                          'Coupon Removed', 
                                          'Coupon removed successfully',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red[100],
                                          colorText: Colors.red[800],
                                        );
                                      },
                                    ),
                                  );
                                }
                              ),
                              
                              SizedBox(height: 20.h * scale),
                              
                              PaymentSummaryBlock(
                                scale: scale,
                                grandTotal: servicePriceInclusive,
                                feeRate: 0.20,
                                gstOnFeeRate: 0.18,
                                showSavingsTag: false,
                                discountAmount: discountAmount,
                              ),
                              
                              SizedBox(height: 70.h * scale),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom CTA
                if (hasCurrentPageItems)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.h * scale, vertical: 12.h * scale),
                      child: SafeArea(
                        top: false,
                        child: Obx(() {
                          final placing = _bookingController.isPlacing.value;

                          return _showEditableBlocks
                              ? InkWell(
                                  onTap: placing
                                      ? null
                                      : () async {
                                          // Validate inputs
                                          if ((_locationId ?? '').isEmpty) {
                                            Get.snackbar('Address required', 'Please select an address', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green[100], colorText: Colors.green[800], margin: const EdgeInsets.all(12), borderRadius: 8);
                                            return;
                                          }

                                          if (saathi == null || (saathi?['id']?.toString().isEmpty ?? true)) {
                                            Get.snackbar('Saathi required', 'Please select a Chayan Saathi', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green[100], colorText: Colors.green[800], margin: const EdgeInsets.all(12), borderRadius: 8);
                                            return;
                                          }

                                          if (_inlineTime == null) {
                                            Get.snackbar('Time required', 'Please select a preferred time', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green[100], colorText: Colors.green[800], margin: const EdgeInsets.all(12), borderRadius: 8);
                                            return;
                                          }

                                          final preferredDateTime = _resolveBookingDateTime(
                                              RegExp(r'^(\d{4}-\d{2}-\d{2})').hasMatch(timeSlot)
                                                  ? timeSlot
                                                  : (RegExp(r'\b(\d{2})\b').firstMatch(timeSlot)?.group(1) ?? DateFormat('dd').format(DateTime.now())),
                                              _inlineTime,
                                          );

                                          final currentItems = _getCurrentPageCartItems(Get.find<CartController>());
                                          if (currentItems.isEmpty) {
                                            Get.snackbar('No service', 'Please add at least one service');
                                            return;
                                          }

                                          final bookingItems = _mapCartToBookingItems(currentItems);
                                          final totalDuration = _estimateTotalDurationMinutes(currentItems);
                                          final spId = saathi!['id'].toString();
                                          final addressId = _addressId!;
                                          final paymentMode = _paymentMethod == PaymentMethod.afterService ? 'CASH' : 'ONLINE';
                                          final dateStr = "${preferredDateTime.year.toString().padLeft(4, '0')}-${preferredDateTime.month.toString().padLeft(2, '0')}-${preferredDateTime.day.toString().padLeft(2, '0')}";
        final firstItem = currentItems.first;
        final title = firstItem.name;
        final imageUrl = firstItem.image;

                                          if (_paymentMethod == PaymentMethod.online) {
                                            try {
                                              final res = await _bookingController.placeBooking(
                                                spId: spId,
                                                addressId: addressId,
                                                slot: preferredDateTime,
                                                paymentMode: 'ONLINE',
                                                services: bookingItems,
                                                totalDuration: totalDuration,
                                              );

                                              if (!(res.success) || (res.bookingId ?? '').isEmpty) {
                                                Get.snackbar('Error', res.message.isNotEmpty ? res.message : 'Failed to create booking for online payment');
                                                return;
                                              }

                                              final bookingId = res.bookingId!;
                                              
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => const PaymentScreen(),
                                                  settings: RouteSettings(arguments: {
                                                    'amount': total,
                                                    'bookingId': bookingId,
                                                    'paymentMethod': 'online',
                                                    'preferredTime': DateFormat('hh:mm a').format(preferredDateTime),
                                                    'bookingCard': {
                    'bookingId': bookingId,
                    'bookingDate': dateStr,
                    'serviceTitle': title,
                    'totalDuration': totalDuration, // Passing INT minutes (e.g., 90)
                    'imageUrl': imageUrl,
                  }
                                                  }),
                                                ),
                                              );
                                            } catch (e) {
                                              Get.snackbar('Error', e.toString());
                                            }
                                            return;
                                          }

                                          try {
                                            final res = await _bookingController.placeBooking(
                                              spId: spId,
                                              addressId: addressId,
                                              slot: preferredDateTime,
                                              paymentMode: paymentMode,
                                              services: bookingItems,
                                              totalDuration: totalDuration,
                                            );

                                            if (res.success && (res.bookingId?.isNotEmpty ?? false)) {
                                              final dateStr = "${preferredDateTime.year.toString().padLeft(4, '0')}-${preferredDateTime.month.toString().padLeft(2, '0')}-${preferredDateTime.day.toString().padLeft(2, '0')}";
                                              final firstItem = currentItems.first;
                                              final title = firstItem.name;
                                              final int hours = totalDuration ~/ 60; // Integer division (90 ~/ 60 = 1)
final int minutes = totalDuration % 60; // Remainder (90 % 60 = 30)

String dur;
if (totalDuration < 60) {
  dur = '$totalDuration min';
} else if (minutes == 0) {
  dur = '$hours hr';
} else {
  dur = '$hours hr $minutes m'; // This gives "1 hr 30 m"
}

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => BookingSuccessfulScreen(
                                                    bookingId: res.bookingId!,
                                                    bookingDate: dateStr,
                                                    serviceTitle: title,
                                                    durationLabel: dur,
                                                    imageUrl: firstItem.image,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Get.snackbar('Provider unavailable', res.message.isNotEmpty ? res.message : 'Could not place booking', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green[100], colorText: Colors.green[800], borderRadius: 8, duration: const Duration(seconds: 3));
                                            }
                                          } catch (e) {
                                            Get.snackbar('Error', _bookingController.error.value.isEmpty ? e.toString() : _bookingController.error.value);
                                          }
                                        },
                                  child: Container(
                                    height: 47.h * scale,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFE47830),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      placing
                                          ? 'Placing...'
                                          : (_paymentMethod == PaymentMethod.online ? 'Pay Now (${inr.format(total)})' : 'Confirm & Book'),
                                      style: TextStyle(color: Colors.white, fontSize: 14.sp * scale, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                )
                              : InkWell(
                                  onTap: () async {
                                    // A. Check Address (Silent load should have handled this)
                                    if ((_locationId ?? '').isEmpty) {
                                      // Fallback: If address missing, ask now
                                      final newAddress = await showScheduleAddressPopup(context);
                                      if (newAddress == null) return;
                                      await _locationController.fetchCustomerAddresses();
                                      final match = _locationController.addresses.firstWhereOrNull((a) {
                                         final existing = _formatAddress(a.addressLine1 ?? "", a.addressLine2 ?? "", a.city ?? "", a.state ?? "", a.postCode ?? "").toLowerCase().trim();
                                         return existing == newAddress.toLowerCase().trim();
                                      });
                                      setState(() {
                                        address = newAddress;
                                        _locationId = match?.locationId ?? _locationId;
                                        _addressId = match?.id ?? _addressId;
                                      });
                                    }

                                    // B. Pick Time
                                    await _openMergedBookingModal();
                                    if (_inlineTime == null) return; // User cancelled time

                                    // C. Pick Saathi
                                    final items = _getCurrentPageCartItems(Get.find<CartController>());
                                    if (items.isEmpty) return;
                                    final first = items.first;
                                    
                                    // Prepare data for Saathi Screen
                                    final DateTime resolvedDate = _resolveBookingDateTime(timeSlot, const TimeOfDay(hour: 0, minute: 0));
                                    final String preciseDateString = DateFormat('yyyy-MM-dd').format(resolvedDate);
                                    final TimeOfDay t = _inlineTime!;
                                    final String timeString = "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
                                    final int totalDuration = _estimateTotalDurationMinutes(items);

                                    final selectedSaathi = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChayanSathiScreen(
                                          categoryId: first.categoryId,
                                          serviceId: first.id,
                                          locationId: _locationId!,
                                          addressId: _addressId!,
                                          initialSlot: preciseDateString,
                                          bookingTime: timeString,
                                          currentBookingDuration: totalDuration,
                                        ),
                                      ),
                                    );

                                    // D. If Saathi Selected -> REVEAL SUMMARY
                                    if (selectedSaathi != null) {
                                      setState(() {
                                        saathi = selectedSaathi;
                                        _showEditableBlocks = true; // This switches the button to "Pay Now" and shows the card
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 47.h * scale,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFE47830),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Request Now (${inr.format(total)})',
                                      style: TextStyle(color: Colors.white, fontSize: 14.sp * scale, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ),
                  ),
                  if (_isGlobalLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3), // Semi-transparent dimming
              child: Center(
                child: ThreeDotLoader(
                  size: 20.0, // Bigger size for full screen
                  color: const Color(0xFFE47830),
                ),
              ),
            ),
              ],
            ),
          ),
        );
      });
    });
  }

  // Cart helpers
  List<CartItem> _getCurrentPageCartItems(CartController cartController) {
    if (widget.currentPageSelectedServices == null || widget.currentPageSelectedServices!.isEmpty) return [];
    return cartController.cartItems
        .where((item) => widget.currentPageSelectedServices!.contains(item.id) && cartController.getQuantity(item.id) > 0)
        .toList();
  }

  double _calculateCurrentPageTotal(List<CartItem> items) {
    double total = 0;
    for (final item in items) {
      final qty = Get.find<CartController>().getQuantity(item.id);
      total += item.price * qty;
    }
    return total;
  }

  int _getCurrentPageItemCount(List<CartItem> items) {
    int count = 0;
    for (final item in items) {
      count += Get.find<CartController>().getQuantity(item.id);
    }
    return count;
  }
  

  Future<void> _loadFrequentlyServicesForCurrentCategory() async {
    final cartController = Get.find<CartController>();
    final categoryController = Get.find<CategoryController>();
    final serviceController = Get.find<ServiceController>();
    final currentItems = _getCurrentPageCartItems(cartController);

    if (currentItems.isEmpty) return;
    final currentCategoryId = currentItems.first.categoryId;
    if (currentCategoryId.isEmpty) return;
    
    setState(() {
      _frequentlyLoading = true;
      _frequentlyServices = [];
    });

    final subCats = categoryController.getServiceSubCategories(currentCategoryId);
    final List<Service> all = [];
    for (final sub in subCats) {
      final scId = sub.serviceCategoryId;
      await serviceController.loadServices(scId);
      all.addAll(serviceController.services);
    }
    
    setState(() {
      _frequentlyServices = all;
      _frequentlyLoading = false;
    });
  }

Widget _buildServiceItem(CartItem cartItem, double scale, bool showControls) {
  final cartController = Get.find<CartController>();
  final totalItemPrice = cartItem.price * cartItem.quantity;
  
  // CHECK: Is the limit reached?
  final bool isMaxLimit = cartItem.quantity >= 3;

  return Container(
    margin: EdgeInsets.only(bottom: 12.h * scale),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- IMAGE BLOCK (Clean, no loader here) ---
        ClipRRect(
          borderRadius: BorderRadius.circular(12 * scale),
          child: Image.network(
            cartItem.image,
            width: 60.w * scale,
            height: 60.h * scale,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 60.w * scale,
              height: 60.h * scale,
              color: Colors.grey[300],
              child: Icon(Icons.image, color: Colors.grey, size: 30 * scale),
            ),
          ),
        ),
        SizedBox(width: 12.w * scale),

        // --- DETAILS BLOCK ---
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.name,
                          style: TextStyle(
                            fontSize: 14.sp * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h * scale),

                        if (!showControls) ...[
                          // LOCKED STATE
                          Text(
                            'Quantity: ${cartItem.quantity} × ₹${cartItem.price.toInt()}',
                            style: TextStyle(fontSize: 12.sp * scale, color: Colors.grey[600], fontWeight: FontWeight.w500),
                          ),
                        ] else ...[
                          // EDITABLE STATE
                          Container(
                            width: 90.w * scale,
                            padding: EdgeInsets.symmetric(horizontal: 4.w * scale, vertical: 2.h * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6 * scale),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Decrement
                                InkWell(
                                  onTap: _isGlobalLoading 
                                      ? null 
                                      : () => _updateServiceQty(cartItem.id, false),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0 * scale),
                                    child: Icon(Icons.remove, size: 16 * scale, color: Colors.black),
                                  ),
                                ),
                                // Quantity
                                Text(
                                  '${cartItem.quantity}',
                                  style: TextStyle(fontSize: 13.sp * scale, fontWeight: FontWeight.w600, color: const Color(0xFFE47830)),
                                ),
                                // Increment
                                InkWell(
                                  onTap: (_isGlobalLoading || isMaxLimit)
                                      ? null
                                      : () => _updateServiceQty(cartItem.id, true),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0 * scale),
                                    child: Icon(
                                      Icons.add,
                                      size: 16 * scale,
                                      // Grey out if limit reached
                                      color: isMaxLimit ? Colors.grey[400] : const Color(0xFFE47830),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // ... Rest of rating/duration code ...
                         if (cartItem.rating.isNotEmpty &&
                              cartItem.duration.isNotEmpty) ...[
                            SizedBox(height: 4.h * scale),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/star.svg',
                                    width: 12.w, height: 12.h, color: Colors.black),
                                SizedBox(width: 2.w * scale),
                                Text(
                                  '${cartItem.rating} | ${cartItem.duration}',
                                  style: TextStyle(
                                      fontSize: 11.sp * scale,
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w * scale),
                  // ... Price Code ...
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${totalItemPrice.toInt()}',
                        style: TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w700, color: const Color(0xFFE47830)),
                      ),
                      if (cartItem.hasDiscount) ...[
                        SizedBox(height: 2.h * scale),
                        Text(
                          '₹${(cartItem.originalPrice * cartItem.quantity).toInt()}',
                          style: TextStyle(fontSize: 12.sp * scale, decoration: TextDecoration.lineThrough, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (cartItem.description.isNotEmpty) ...[
                SizedBox(height: 8.h * scale),
                BulletText(cartItem.description, scale: scale),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
}

class _TopDetailsBlock extends StatelessWidget {
  final double scale;
  final String address;
  final String timeLabel;
  final Map<String, dynamic>? saathi;
  final VoidCallback onEditAddress;
  final VoidCallback onEditTime;
  final VoidCallback onEditSaathi;

  const _TopDetailsBlock({
    required this.scale,
    required this.address,
    required this.timeLabel,
    required this.saathi,
    required this.onEditAddress,
    required this.onEditTime,
    required this.onEditSaathi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.07), blurRadius: 8 * scale, offset: Offset(0, 2 * scale))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(icon: 'assets/icons/home.svg', title: 'Home', value: address, onEdit: onEditAddress, scale: scale),
          SizedBox(height: 14.h * scale),
          _row(icon: 'assets/icons/calendar.svg', title: 'Scheduled', value: timeLabel, onEdit: onEditTime, scale: scale),
          SizedBox(height: 14.h * scale),
          _row(
            icon: 'assets/icons/chayansathi.svg',
            title: 'Chayan Saathi',
            value: saathi == null
                ? 'Select Chayan Saathi'
                : "${saathi!['name']}, (${saathi!['jobs'] ?? ''}+ work), ${saathi!['rating'] ?? ''} rating",
            onEdit: onEditSaathi,
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _row({
    required String icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
    required double scale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 22 * scale, height: 22 * scale, color: Colors.black),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp * scale, color: Colors.black)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp * scale, color: Colors.black)),
          ]),
        ),
        InkWell(onTap: onEdit, child: Icon(Icons.edit, size: 18 * scale, color: const Color(0xFFE47830))),
      ],
    );
  }
}

class _SelectedServicesBlock extends StatelessWidget {
  final List<CartItem> items;
  final double scale;
  final Widget Function(CartItem) buildItem;

  const _SelectedServicesBlock({required this.items, required this.scale, required this.buildItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r * scale),
      decoration: BoxDecoration(color: const Color(0xFFE5E9FF), borderRadius: BorderRadius.circular(20 * scale)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Services (${items.fold<int>(0, (p, e) => p + e.quantity)} items)',
              style: TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h * scale),
          ...items.map(buildItem).toList(),
        ],
      ),
    );
  }
}

class _EmptyServicesBlock extends StatelessWidget {
  final double scale;
  const _EmptyServicesBlock({required this.scale});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.r * scale),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20 * scale)),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64 * scale, color: Colors.grey),
            SizedBox(height: 16.h * scale),
            Text('No services selected from this page',
                style: TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            SizedBox(height: 8.h * scale),
            Text('Go back and select services to proceed', style: TextStyle(fontSize: 14.sp * scale, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

class _CouponsRow extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;
  final CouponModel? selectedCoupon;
  final double discountAmount;

  const _CouponsRow({
    required this.scale, 
    required this.onTap,
    this.selectedCoupon,
    this.discountAmount = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * scale),
           boxShadow: [
             BoxShadow(
               color: Colors.grey.withOpacity(0.07),
               blurRadius: 8 * scale,
               offset: Offset(0, 2 * scale),
             ),
           ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.local_offer_outlined, size: 20 * scale, color: selectedCoupon != null ? Colors.green : Colors.black),
              SizedBox(width: 8.w * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coupons and offers', 
                    style: TextStyle(fontSize: 14.sp * scale, fontWeight: FontWeight.w600)
                  ),
                  if (selectedCoupon != null)
                    Text(
                      '${selectedCoupon!.code} applied',
                      style: TextStyle(fontSize: 12.sp * scale, color: Colors.green, fontWeight: FontWeight.w500),
                    )
                ],
              ),
            ]),
            Row(
              children: [
                if(selectedCoupon != null && discountAmount > 0)
                   Text(
                    '-₹${discountAmount.toInt()}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green, fontSize: 14.sp * scale),
                  )
                else if (selectedCoupon != null)
                   Text(
                    'Add items > ₹${selectedCoupon!.minOrderAmount.toInt()}',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange, fontSize: 12.sp * scale),
                   )
                else
                   Text('1 offer', style: TextStyle(fontWeight: FontWeight.w800, color: const Color(0xFFFA9441))),
                
                SizedBox(width: 4.w * scale),
                Icon(Icons.chevron_right, color: const Color(0xFFFA9441), size: 18 * scale)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSummaryBlock extends StatelessWidget {
  final double scale;
  final int grandTotal;
  final double feeRate;
  final double gstOnFeeRate;
  final bool showSavingsTag;
  final double discountAmount;

  const PaymentSummaryBlock({
    super.key,
    required this.scale,
    required this.grandTotal,
    this.feeRate = 0.20,
    this.gstOnFeeRate = 0.18,
    this.showSavingsTag = false,
    this.discountAmount = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final int booking = grandTotal;
    final int platformFee = (booking * feeRate).round();        
    final int perService  = (booking * (1 - feeRate)).round();  
    final int gst         = (platformFee * gstOnFeeRate).round(); 
    
    final int subTotal = perService + platformFee + gst;
    final int total = (subTotal - discountAmount).toInt() > 0 ? (subTotal - discountAmount).toInt() : 0;

    return Container(
      padding: EdgeInsets.all(16.r * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10 * scale,
            offset: Offset(0, 2 * scale),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary',
              style: TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h * scale),

          PriceRow(title: 'Per Service Charge',  amount: '₹${perService.toString()}',  scale: scale),
          PriceRow(title: 'Platform Fee',    amount: '₹${platformFee.toString()}', scale: scale),
          PriceRow(title: 'GST on Platform (18%)', amount: '₹${gst.toString()}',          scale: scale, color: Colors.black87),
          
          if (discountAmount > 0)
             Padding(
               padding: EdgeInsets.symmetric(vertical: 2.h * scale),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('Coupon Discount', style: TextStyle(fontSize: 14.sp * scale, color: Colors.green)),
                   Text('-₹${discountAmount.toInt()}', style: TextStyle(fontSize: 14.sp * scale, color: Colors.green, fontWeight: FontWeight.w600)),
                 ],
               ),
             ),

          Divider(height: 20.h * scale),
          PriceRow(title: 'Total', amount: '₹$total', isBold: true, scale: scale),
        ],
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  final double scale;
  const BulletText(this.text, {super.key, this.scale = 1});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h * scale),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 6.r * scale, top: 4.r * scale),
            child: CircleAvatar(radius: 2 * scale, backgroundColor: const Color(0xFF757575)),
          ),
          Flexible(child: Text(text, style: TextStyle(color: const Color(0xFF757575), fontSize: 12.sp * scale))),
        ],
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String title;
  final String amount;
  final Color? color;
  final bool isBold;
  final double scale;

  const PriceRow({
    super.key,
    required this.title,
    required this.amount,
    this.color,
    this.isBold = false,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp * scale, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
          Text(amount,
              style: TextStyle(
                  fontSize: 14.sp * scale, color: color ?? Colors.black, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

class _Agg {
  _Agg({required this.categoryId, required this.serviceId, required this.discountPct});
  final String categoryId;
  final String serviceId;
  final int discountPct;
  num price = 0;
  num discountPrice = 0;
}

// --- COUPON BOTTOM SHEET ---
class CouponsBottomSheet extends StatefulWidget {
  final double scale;
  final Function(CouponModel) onApply;
  final VoidCallback onRemove;
  final CouponModel? selectedCoupon;

  const CouponsBottomSheet({
      Key? key, 
      required this.scale, 
      required this.onApply,
      required this.onRemove,
      this.selectedCoupon,
  }) : super(key: key);

  @override
  State<CouponsBottomSheet> createState() => _CouponsBottomSheetState();
}

class _CouponsBottomSheetState extends State<CouponsBottomSheet> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w * scale, vertical: 16.h * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Coupons & Offers',
                  style: TextStyle(fontSize: 18.sp * scale, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24 * scale),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w * scale, vertical: 16.h * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w * scale),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            onChanged: (val) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Enter Coupon Code',
                              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp * scale),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                             final inputCode = _codeController.text.trim();
                             if (inputCode.isEmpty) return;
                             CouponModel? validCoupon;
                             try {
                               validCoupon = mockCoupons.firstWhere(
                                 (c) => c.code.toLowerCase() == inputCode.toLowerCase()
                               );
                             } catch (e) {
                               validCoupon = null;
                             }
                             if (validCoupon != null) {
                               Navigator.pop(context);
                               widget.onApply(validCoupon);
                             } else {
                               Get.snackbar(
                                 'Invalid Coupon',
                                 'Please enter valid coupon',
                                 snackPosition: SnackPosition.TOP,
                                 backgroundColor: Colors.red[100],
                                 colorText: Colors.red[800],
                                 margin: const EdgeInsets.all(10),
                                 borderRadius: 8,
                                 duration: const Duration(seconds: 2),
                               );
                             }
                          },
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              color: _codeController.text.isNotEmpty 
                                  ? const Color(0xFFE47830) 
                                  : Colors.grey[400], 
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp * scale
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h * scale),
                  Text(
                    'Payment offers',
                    style: TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'No code required',
                    style: TextStyle(fontSize: 13.sp * scale, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16.h * scale),

                  ...mockCoupons.map((coupon) => _buildCouponItem(coupon, scale)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponItem(CouponModel coupon, double scale) {
    final bool isSelected = widget.selectedCoupon?.id == coupon.id;

    return InkWell(
      onTap: () {
        if (!isSelected) {
            widget.onApply(coupon);
            Navigator.pop(context);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w * scale,
              height: 40.h * scale,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Center(
                child: Icon(Icons.account_balance_wallet, color: coupon.iconColor, size: 20 * scale), 
              ),
            ),
            SizedBox(width: 12.w * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.title,
                    style: TextStyle(fontSize: 15.sp * scale, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h * scale),
                  Text(
                    coupon.description,
                    style: TextStyle(fontSize: 13.sp * scale, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h * scale),
                  Text(
                    'View T&C',
                    style: TextStyle(
                      fontSize: 12.sp * scale, 
                      fontWeight: FontWeight.w600, 
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
                onTap: () {
                    if (isSelected) {
                        widget.onRemove();
                        Navigator.pop(context);
                    } else {
                        widget.onApply(coupon);
                        Navigator.pop(context);
                    }
                },
                child: Container(
                   padding: EdgeInsets.symmetric(horizontal: 12.w * scale, vertical: 6.h * scale),
                   decoration: BoxDecoration(
                     border: Border.all(color: isSelected ? Colors.red : const Color(0xFFE47830)),
                     borderRadius: BorderRadius.circular(20 * scale)
                   ),
                   child: Text(
                       isSelected ? 'REMOVE' : 'APPLY', 
                       style: TextStyle(
                           color: isSelected ? Colors.red : const Color(0xFFE47830), 
                           fontSize: 12.sp * scale, 
                           fontWeight: FontWeight.bold
                       ),
                   ),
                ),
            )
          ],
        ),
      ),
    );
  }
}