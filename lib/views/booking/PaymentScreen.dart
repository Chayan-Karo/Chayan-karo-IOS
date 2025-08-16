import 'package:chayankaro/views/booking/PaymentSuccess.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import '../../widgets/chayan_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedMethod;

  void _onSelect(String method) {
    setState(() {
      selectedMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(builder: (context, constraints) {
      final bool isTablet = constraints.maxWidth > 600;
      final double scale = isTablet ? constraints.maxWidth / 411 : 1.0;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: const Color(0xFFFFEEE0),
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  ChayanHeader(
                    title: 'Payment Option',
                    onBackTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w * scale),
                      child: ListView(
                        padding: EdgeInsets.only(bottom: 100.r * scale),
                        children: [
                          SizedBox(height: 16.h * scale),
                          Text('UPI', style: _sectionTitleStyle(scale)),
                          _paymentTile('Paytm UPI', 'assets/icons/paytm.svg', scale),
                          _paymentTile('PhonePe', 'assets/icons/phonepe.svg', scale),
                          _paymentTile('GPay', 'assets/icons/gpay.svg', scale),
                          SizedBox(height: 24.h * scale),
                          Text('Cards', style: _sectionTitleStyle(scale)),
                          _cardTile(scale),
                          SizedBox(height: 24.h * scale),
                          Text('Cash', style: _sectionTitleStyle(scale)),
                          _paymentTile('Cash', 'assets/icons/cash.svg', scale),
                          SizedBox(height: 24.h * scale),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 16.h * scale),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.h * scale, vertical: 12.h * scale),
                  child: GestureDetector(
                    onTap: selectedMethod != null
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
                            )
                        : null,
                    child: Container(
                      height: 47.h * scale,
                      decoration: BoxDecoration(
                        color: selectedMethod != null
                            ? const Color(0xFFE47830)
                            : const Color(0xFFD7D7D7),
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: selectedMethod != null
                              ? Colors.white
                              : const Color(0xFF858585),
                          fontSize: 16.sp * scale,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _paymentTile(String title, String iconPath, double scale) {
    final isSelected = selectedMethod == title;
    final isCashIcon = iconPath == 'assets/icons/cash.svg';

    return GestureDetector(
      onTap: () => _onSelect(title),
      child: Padding(
        padding: EdgeInsets.only(top: 16.r * scale),
        child: Row(
          children: [
            Container(
              width: 16.w * scale,
              height: 16.h * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF161616), width: 1.w * scale),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w * scale,
                        height: 10.h * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE47830),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w * scale),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp * scale,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: const Color(0xFF161616),
              ),
            ),
            const Spacer(),
            Container(
              width: 35.w * scale,
              height: 35.h * scale,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Padding(
                padding: EdgeInsets.all(6.r * scale),
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  color: isCashIcon ? Colors.black : null,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _cardTile(double scale) {
    final isSelected = selectedMethod == 'Card';

    return GestureDetector(
      onTap: () => _onSelect('Card'),
      child: Padding(
        padding: EdgeInsets.only(top: 16.r * scale),
        child: Row(
          children: [
            Container(
              width: 16.w * scale,
              height: 16.h * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF161616), width: 1.w * scale),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w * scale,
                        height: 10.h * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE47830),
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 16.w * scale),

            // Mastercard icon
            Container(
              width: 32.w * scale,
              height: 32.h * scale,
              margin: EdgeInsets.only(right: 10.r * scale),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: SvgPicture.asset(
                  'assets/icons/mastercard.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Text(
              '************2575',
              style: TextStyle(
                fontSize: 16.sp * scale,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
                color: const Color(0xFF161616),
              ),
            ),
            const Spacer(),

            // card icon on right
            Container(
              width: 32.w * scale,
              height: 32.h * scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8 * scale),
                child: SvgPicture.asset(
                  'assets/icons/cc.svg',
                  fit: BoxFit.contain,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle _sectionTitleStyle(double scale) => TextStyle(
      fontSize: 16.sp * scale,
      fontWeight: FontWeight.w700,
      fontFamily: 'SF Pro Display',
      color: const Color(0xFF161616),
    );
