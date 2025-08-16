import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/chayan_header.dart';
import 'showReschedulePopup.dart';
import 'showScheduleAddressPopup.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scale = isTablet ? constraints.maxWidth / 411 : 1.0;

      return Scaffold(
        backgroundColor: const Color(0xFFFFFEFD),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  ChayanHeader(
                    title: 'Summary',
                    onBackTap: () {},
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.h * scale, vertical: 8.h * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected Services Card
                          Container(
                            padding: EdgeInsets.all(16.r * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E9FF),
                              borderRadius:
                                  BorderRadius.circular(20 * scale),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Services',
                                  style: TextStyle(
                                    fontSize: 16.sp * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 12.h * scale),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12 * scale),
                                      child: Image.asset(
                                        'assets/facial.webp',
                                        width: 60.w * scale,
                                        height: 60.h * scale,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 12.w * scale),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Diamond Facial',
                                                  style: TextStyle(
                                                    fontSize: 14.sp * scale,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8.w * scale),
                                              Text(
                                                '₹699',
                                                style: TextStyle(
                                                  fontSize: 16.sp * scale,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFFFA9441),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h * scale),
                                          BulletText('45 mins', scale: scale),
                                          BulletText('For all skin types. Pinacolada mask.',
                                              scale: scale),
                                          BulletText(
                                              '6-step process. Includes 10-min massage',
                                              scale: scale),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.h * scale),

                          // Frequently Added Together
                          Text(
                            'Frequently added together',
                            style: TextStyle(
                              fontSize: 16.sp * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h * scale),
                          SizedBox(
                            height: 240.h * scale,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                buildAddCard(
                                    'assets/saloon_manicure.webp', 'Manicure', '₹499', scale),
                                buildAddCard(
                                    'assets/saloon_pedicure.webp', 'Pedicure', '₹499', scale),
                                buildAddCard(
                                    'assets/saloon_threading.webp', 'Threading', '₹49', scale),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h * scale),

                          // Coupons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_offer_outlined,
                                      size: 20 * scale),
                                  SizedBox(width: 8.w * scale),
                                  Text(
                                    'Coupons and offers',
                                    style: TextStyle(fontSize: 14.sp * scale),
                                  ),
                                ],
                              ),
                              Text(
                                '2 offer  >',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFA9441),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h * scale),

                          // Payment Summary
                          Container(
                            padding: EdgeInsets.all(16.r * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20 * scale),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Summary',
                                  style: TextStyle(
                                    fontSize: 16.sp * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 12.h * scale),
                                PriceRow(title: 'Item Total', amount: '₹699', scale: scale),
                                PriceRow(
                                    title: 'Item Discount',
                                    amount: '-₹50',
                                    color: const Color(0xFF52B46B),
                                    scale: scale),
                                PriceRow(title: 'Service Fee', amount: '₹50', scale: scale),
                                Divider(height: 20.h * scale),
                                PriceRow(
                                    title: 'Grand Total',
                                    amount: '₹749',
                                    isBold: true,
                                    scale: scale),
                                SizedBox(height: 12.h * scale),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.h * scale, vertical: 6.h * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0x33FFAD33),
                                      borderRadius: BorderRadius.circular(6 * scale),
                                    ),
                                    child: Text(
                                      'Hurray ! You saved ₹50 on final bill',
                                      style: TextStyle(
                                        color: const Color(0xFFFA9441),
                                        fontSize: 12.sp * scale,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 100.h * scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Buttons
              Positioned(
                bottom: 0.r,
                left: 0.r,
                right: 0.r,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.h * scale, vertical: 12.h * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showScheduleAddressPopup(context);
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
                          onTap: () {
                            showReschedulePopup(context);
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
                              'Request Now',
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
            ],
          ),
        ),
      );
    });
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
            ),
          ),
          SizedBox(height: 8.h * scale),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp * scale),
          ),
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
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white, fontSize: 14.sp * scale),
            ),
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
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 6.r * scale, top: 4.r * scale),
          child: CircleAvatar(radius: 2 * scale, backgroundColor: const Color(0xFF757575)),
        ),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: const Color(0xFF757575), fontSize: 14.sp * scale),
          ),
        ),
      ],
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
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp * scale,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14.sp * scale,
              color: color ?? Colors.black,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
