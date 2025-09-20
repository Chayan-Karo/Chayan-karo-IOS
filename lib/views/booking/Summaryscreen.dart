import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widgets/chayan_header.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_models.dart';
import 'showReschedulePopup.dart';
import 'showScheduleAddressPopup.dart';
import '../chayan_sathi/chayan_sathi_screen.dart';
import 'PaymentScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';


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

class _SummaryScreenState extends State<SummaryScreen> {
  late String address;
  late String timeSlot;
  late Map<String, dynamic>? saathi;

  // Control to show/hide the editable fields below buttons
  bool _showEditableFields = false;

  @override
  void initState() {
    super.initState();
    address = "Static address 123, City XYZ"; // static address always
    timeSlot = widget.initialTimeSlot;
    saathi = widget.initialSaathi;
    _showEditableFields = false; // initially hide editable rows
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
        final itemTotal = _calculateCurrentPageTotal(currentPageItems);
        final discount = _calculateDiscount(itemTotal);
        final serviceFee = _calculateServiceFee(_getCurrentPageItemCount(currentPageItems));
        final grandTotal = itemTotal - discount + serviceFee;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFEFD),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    ChayanHeader(
                      title: 'Summary',
                      onBackTap: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.h * scale, vertical: 8.h * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          if (hasCurrentPageItems && _showEditableFields) ...[
  Container(
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/home.svg',
              width: 22 * scale,
              height: 22 * scale,
              color: Colors.black,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Home",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp * scale,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    address,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp * scale,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                final newAddress = await showScheduleAddressPopup(context);
                if (newAddress != null) {
                  setState(() {
                    address = newAddress;
                  });
                }
              },
              child: Icon(
                Icons.edit,
                size: 18 * scale,
                color: const Color(0xFFE47830),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h * scale),
        // Time row
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/calendar.svg',
              width: 22 * scale,
              height: 22 * scale,
              color: Colors.black,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                timeSlot,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp * scale,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final newTime = await showReschedulePopup(context, initialSlot: timeSlot);
                if (newTime != null) {
                  setState(() {
                    timeSlot = newTime;
                  });
                }
              },
              child: Icon(
                Icons.edit,
                size: 18 * scale,
                color: const Color(0xFFE47830),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h * scale),
        // Saathi row
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/chayansathi.svg',
              width: 22 * scale,
              height: 22 * scale,
              color: Colors.black,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                saathi == null
                    ? 'Select Chayan Saathi'
                    : "${saathi!['name']}, (${saathi!['jobs'] ?? ''}+ work), ${saathi!['rating'] ?? ''} rating",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp * scale,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                final selectedSaathi = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChayanSathiScreen()),
                );
                if (selectedSaathi != null) {
                  setState(() {
                    saathi = selectedSaathi;
                  });
                }
              },
              child: Icon(
                Icons.edit,
                size: 18 * scale,
                color: const Color(0xFFE47830),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  SizedBox(height: 18.h * scale),
],


                            // Selected Services section (unchanged)
                            if (hasCurrentPageItems) ...[
                              Container(
                                padding: EdgeInsets.all(16.r * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E9FF),
                                  borderRadius: BorderRadius.circular(20 * scale),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Services (${_getCurrentPageItemCount(currentPageItems)} items)',
                                      style: TextStyle(
                                          fontSize: 16.sp * scale, fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 12.h * scale),
                                    ...currentPageItems
                                        .map((cartItem) => _buildServiceItem(cartItem, scale))
                                        .toList(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h * scale),
                            ],
                            if (!hasCurrentPageItems) ...[
                              Container(
                                padding: EdgeInsets.all(32.r * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(20 * scale),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.shopping_cart_outlined,
                                          size: 64 * scale, color: Colors.grey),
                                      SizedBox(height: 16.h * scale),
                                      Text(
                                        'No services selected from this page',
                                        style: TextStyle(
                                            fontSize: 16.sp * scale,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600]),
                                      ),
                                      SizedBox(height: 8.h * scale),
                                      Text(
                                        'Go back and select services to proceed',
                                        style: TextStyle(
                                            fontSize: 14.sp * scale, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h * scale),
                            ],

                            // Frequently Added Together (unchanged)
                            Text(
                              'Frequently added together',
                              style:
                                  TextStyle(fontSize: 16.sp * scale, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(height: 12.h * scale),
                            SizedBox(
                              height: 240.h * scale,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  buildAddCard('assets/saloon_manicure.webp', 'Manicure', '₹499',
                                      scale),
                                  buildAddCard('assets/saloon_pedicure.webp', 'Pedicure', '₹499',
                                      scale),
                                  buildAddCard('assets/saloon_threading.webp', 'Threading', '₹49',
                                      scale),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h * scale),

                            // Coupons and offers (unchanged)
                            if (hasCurrentPageItems) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.local_offer_outlined, size: 20 * scale),
                                      SizedBox(width: 8.w * scale),
                                      Text('Coupons and offers', style: TextStyle(fontSize: 14.sp * scale)),
                                    ],
                                  ),
                                  Text(
                                    '2 offers  >',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFFA9441)),
                                  )
                                ],
                              ),
                              SizedBox(height: 20.h * scale),
                            ],

                            // Payment summary (unchanged)
                            if (hasCurrentPageItems) ...[
                              Container(
                                padding: EdgeInsets.all(16.r * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20 * scale),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10 * scale,
                                      offset: Offset(0, 2 * scale),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Summary',
                                      style: TextStyle(
                                          fontSize: 16.sp * scale, fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(height: 12.h * scale),
                                    PriceRow(
                                      title:
                                          'Item Total (${_getCurrentPageItemCount(currentPageItems)} items)',
                                      amount: '₹${itemTotal.toInt()}',
                                      scale: scale,
                                    ),
                                    if (discount > 0) ...[
                                      PriceRow(
                                        title: 'Item Discount',
                                        amount: '-₹${discount.toInt()}',
                                        color: const Color(0xFF52B46B),
                                        scale: scale,
                                      ),
                                    ],
                                    PriceRow(
                                      title: 'Service Fee',
                                      amount: '₹${serviceFee.toInt()}',
                                      scale: scale,
                                    ),
                                    Divider(height: 20.h * scale),
                                    PriceRow(
                                      title: 'Grand Total',
                                      amount: '₹${grandTotal.toInt()}',
                                      isBold: true,
                                      scale: scale,
                                    ),
                                    SizedBox(height: 12.h * scale),
                                    if (discount > 0)
                                      Center(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.h * scale, vertical: 6.h * scale),
                                          decoration: BoxDecoration(
                                            color: const Color(0x33FFAD33),
                                            borderRadius: BorderRadius.circular(6 * scale),
                                          ),
                                          child: Text(
                                            'Hurray! You saved ₹${discount.toInt()} on final bill',
                                            style: TextStyle(
                                                color: const Color(0xFFFA9441),
                                                fontSize: 12.sp * scale,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                              SizedBox(height: 70.h * scale),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (hasCurrentPageItems)
                  Positioned(
                    bottom: 0.r,
                    left: 0.r,
                    right: 0.r,
                    child: Container(
                      color: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.h * scale, vertical: 12.h * scale),
                      child: SafeArea(
                        top: false,
                        child: _showEditableFields
                            ? // Show Pay Now button after request flow completed
                            InkWell(
                                onTap: () {
                                  // Navigate to payment screen or process payment
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PaymentScreen()),
                                  );
                                },
                                child: Container(
                                  height: 47.h * scale,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFE47830),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Pay Now (₹${grandTotal.toInt()})',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp * scale,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : // Initial Schedule for later and Request Now buttons
                            Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final newAddress = await showScheduleAddressPopup(context);
                                        if (newAddress != null) {
                                          setState(() {
                                            address = newAddress;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 47.h * scale,
                                        decoration: ShapeDecoration(
                                          color: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10 * scale),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Schedule for later',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp * scale,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w * scale),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        // 1. Show reschedule popup for selecting slot, passing current timeSlot
                                        final selectedSlot = await showReschedulePopup(context, initialSlot: timeSlot);
                                        if (selectedSlot == null) return;

                                        setState(() {
                                          timeSlot = selectedSlot;
                                        });

                                        // 2. Navigate to Chayan Sathi Screen for selection, passing current saathi
                                        final selectedSaathi = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ChayanSathiScreen()),
);

                                        if (selectedSaathi == null) return;

                                        setState(() {
                                          saathi = selectedSaathi;
                                          _showEditableFields = true; // Show fields and switch buttons
                                        });
                                      },
                                      child: Container(
                                        height: 47.h * scale,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFE47830),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10 * scale),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Request Now (₹${grandTotal.toInt()})',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.sp * scale,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  List<CartItem> _getCurrentPageCartItems(CartController cartController) {
    if (widget.currentPageSelectedServices == null || widget.currentPageSelectedServices!.isEmpty) {
      return [];
    }
    return cartController.cartItems
        .where((item) =>
            widget.currentPageSelectedServices!.contains(item.id) && cartController.getQuantity(item.id) > 0)
        .toList();
  }

  double _calculateCurrentPageTotal(List<CartItem> currentPageItems) {
    double total = 0;
    for (CartItem item in currentPageItems) {
      final quantity = Get.find<CartController>().getQuantity(item.id);
      total += item.price * quantity;
    }
    return total;
  }

  int _getCurrentPageItemCount(List<CartItem> currentPageItems) {
    int count = 0;
    for (CartItem item in currentPageItems) {
      count += Get.find<CartController>().getQuantity(item.id);
    }
    return count;
  }

  double _calculateDiscount(double itemTotal) {
    if (itemTotal >= 1000) return itemTotal * 0.15;
    if (itemTotal >= 500) return itemTotal * 0.10;
    if (itemTotal >= 200) return itemTotal * 0.05;
    return 0;
  }

  double _calculateServiceFee(int itemCount) {
    if (itemCount >= 5) return 100;
    if (itemCount >= 3) return 75;
    if (itemCount >= 1) return 50;
    return 0;
  }

  Widget _buildServiceItem(CartItem cartItem, double scale) {
    final totalItemPrice = cartItem.price * cartItem.quantity;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: Image.asset(
              cartItem.image,
              width: 60.w * scale,
              height: 60.h * scale,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60.w * scale,
                  height: 60.h * scale,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey, size: 30 * scale),
                );
              },
            ),
          ),
          SizedBox(width: 12.w * scale),
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
                            cartItem.title,
                            style: TextStyle(
                              fontSize: 14.sp * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (cartItem.quantity > 1) ...[
                            SizedBox(height: 4.h * scale),
                            Text(
                              'Quantity: ${cartItem.quantity} × ₹${cartItem.price.toInt()}',
                              style: TextStyle(
                                fontSize: 12.sp * scale,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (cartItem.rating != null && cartItem.duration != null) ...[
                            SizedBox(height: 4.h * scale),
                            Row(
                              children: [
                                Icon(Icons.star, size: 12 * scale, color: Colors.amber),
                                SizedBox(width: 2.w * scale),
                                Text(
                                  '${cartItem.rating} | ${cartItem.duration}',
                                  style: TextStyle(
                                    fontSize: 11.sp * scale,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w * scale),
                    Text(
                      '₹${totalItemPrice.toInt()}',
                      style: TextStyle(
                        fontSize: 16.sp * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE47830),
                      ),
                    ),
                  ],
                ),
                if (cartItem.description != null && cartItem.description!.isNotEmpty) ...[
                  SizedBox(height: 8.h * scale),
                  BulletText(cartItem.description!, scale: scale),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddCard(String asset, String title, String price, double scale) {
    return Container(
      width: 140.w * scale,
      margin: EdgeInsets.only(right: 16.r * scale),
      padding: EdgeInsets.all(8.r * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(25 * scale),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14 * scale),
            child: Image.asset(
              asset,
              width: 120.w * scale,
              height: 120.h * scale,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120.w * scale,
                  height: 120.h * scale,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(height: 8.h * scale),
          Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp * scale)),
          SizedBox(height: 4.h * scale),
          Text(price, style: TextStyle(fontSize: 14.sp * scale)),
          SizedBox(height: 8.h * scale),
          Container(
            width: 120.w * scale,
            height: 30.h * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFE47830),
              borderRadius: BorderRadius.circular(30 * scale),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                )
              ],
            ),
            alignment: Alignment.center,
            child: Text('Add', style: TextStyle(color: Colors.white, fontSize: 14.sp * scale)),
          ),
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
          Flexible(
            child:
                Text(text, style: TextStyle(color: const Color(0xFF757575), fontSize: 12.sp * scale)),
          ),
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
          Text(amount, style: TextStyle(fontSize: 14.sp * scale, color: color ?? Colors.black, fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}

