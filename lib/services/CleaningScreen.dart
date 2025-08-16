import 'package:chayankaro/views/cart/cart_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CleaningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        // Set status bar color to match header
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: const Color(0xFFFFEEE0), // Matches header background
          statusBarIconBrightness: Brightness.dark, // For dark icons
        ));

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 74.r * scaleFactor), // 54 (header) + 20 (gap)
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: (120.r + MediaQuery.of(context).viewPadding.bottom + 8.h) * scaleFactor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h * scaleFactor),
                      _buildTopBanner(scaleFactor),
                      SizedBox(height: 12.h * scaleFactor),
                      _buildSalonInfoBlock(scaleFactor),
                      SizedBox(height: 16.h * scaleFactor),
                      _buildDiscountCards(scaleFactor),
                      SizedBox(height: 16.h * scaleFactor),
                      _buildCustomPackageSection(scaleFactor),
                      SizedBox(height: 16.h * scaleFactor),
                      _buildCategoryGrid(scaleFactor),
                      SizedBox(height: 16.h * scaleFactor),
                      _buildServiceCards(scaleFactor),
                      SizedBox(height: 16.h * scaleFactor),
                    ],
                  ),
                ),
              ),

              // Sticky header on top
              Positioned(
                top: 0.r,
                left: 0.r,
                right: 0.r,
                child: Container(
                  color: const Color(0xFFFFEEE0),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: _buildHeader(context, scaleFactor),
                ),
              ),

              // Bottom bar
              _buildBottomBar(scaleFactor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, double scaleFactor) {
    return Container(
      width: double.infinity,
      height: 48.h * scaleFactor,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE0),
        boxShadow: [
          BoxShadow(
            color: const Color(0x26000000),
            blurRadius: 4 * scaleFactor,
            offset: Offset(0, 2 * scaleFactor),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new, size: 20 * scaleFactor),
            ),
            SizedBox(width: 8.w * scaleFactor),
            Expanded(
              child: Text(
                "Clean Zone",
                style: TextStyle(
                  fontSize: 16.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w * scaleFactor),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: SvgPicture.asset(
                'assets/icons/cart.svg',
                width: 40.w * scaleFactor,
                height: 40.h * scaleFactor,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * scaleFactor),
        child: Stack(
          children: [
            Image.asset(
              'assets/single_use_product.webp',
              width: double.infinity,
              height: 160.h * scaleFactor,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: 12.r * scaleFactor,
              left: 12.r * scaleFactor,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.h * scaleFactor,
                  vertical: 6.h * scaleFactor,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20 * scaleFactor),
                ),
                child: Text(
                  "Single use products",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp * scaleFactor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSalonInfoBlock(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sweep & Shine",
                style: TextStyle(
                  fontSize: 16.sp * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 12.r * scaleFactor),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/warranty.svg',
                      width: 20.w * scaleFactor,
                      height: 20.h * scaleFactor,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4.w * scaleFactor),
                    Text(
                      'CK safe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp * scaleFactor,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h * scaleFactor),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/star.svg',
                width: 18.w * scaleFactor,
                height: 18.h * scaleFactor,
                color: Colors.black,
              ),
              SizedBox(width: 6.w * scaleFactor),
              Text(
                "4.8 (23k)",
                style: TextStyle(fontSize: 14.sp * scaleFactor),
              ),
            ],
          ),
          SizedBox(height: 4.h * scaleFactor),
          Row(
            children: [
              Container(
                width: 20.w * scaleFactor,
                height: 20.h * scaleFactor,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/tick.svg',
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 6.w * scaleFactor),
              Text(
                "354 jobs completed",
                style: TextStyle(fontSize: 14.sp * scaleFactor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCards(double scaleFactor) {
    final List<Map<String, String>> offers = [
      {
        'icon': 'assets/icons/cash.svg',
        'title': 'Save 15% on every order',
        'subtitle': 'Get Plus now',
      },
      {
        'icon': 'assets/icons/card.svg',
        'title': 'CRED Pay',
        'subtitle': 'Upto Rs. 100 cashback',
      },
    ];

    return SizedBox(
      height: 100.h * scaleFactor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return Container(
            width: 240.w * scaleFactor,
            padding: EdgeInsets.symmetric(
              horizontal: 12.h * scaleFactor,
              vertical: 14.h * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12 * scaleFactor),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  offer['icon']!,
                  width: 28.w * scaleFactor,
                  height: 28.h * scaleFactor,
                  color: Colors.black,
                ),
                SizedBox(width: 12.w * scaleFactor),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offer['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp * scaleFactor,
                        ),
                        softWrap: true,
                        maxLines: 2,
                      ),
                      SizedBox(height: 4.h * scaleFactor),
                      Text(
                        offer['subtitle']!,
                        style: TextStyle(
                          fontSize: 12.sp * scaleFactor,
                          color: Colors.black54,
                        ),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 12.w * scaleFactor),
        itemCount: offers.length,
      ),
    );
  }

  Widget _buildCustomPackageSection(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Container(
        width: double.infinity,
        height: 100.h * scaleFactor,
        padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
        decoration: BoxDecoration(
          color: const Color(0xFFE47830),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/package.svg',
                  width: 58.w * scaleFactor,
                  height: 62.h * scaleFactor,
                ),
                SizedBox(width: 12.w * scaleFactor),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 205.67.w * scaleFactor,
                      height: 26.46.h * scaleFactor,
                      child: Text(
                        'Create a Customer Package',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp * scaleFactor,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h * scaleFactor),
                    SizedBox(
                      width: 156.31.w * scaleFactor,
                      height: 26.46.h * scaleFactor,
                      child: Opacity(
                        opacity: 0.50,
                        child: Text(
                          'Specifically for your needs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp * scaleFactor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 1.85,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16 * scaleFactor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(double scaleFactor) {
    final categories = [
      {'title': 'Bathroom Cleaning', 'image': 'assets/z2.webp'},
      {'title': 'Kitchen Cleaning', 'image': 'assets/s1.webp'},
      {'title': 'Sofa & Carpet Cleaning', 'image': 'assets/s2.webp'},
      {'title': 'Full Home Deep Cleaning', 'image': 'assets/s3.webp'},
      {'title': 'Mattress Cleaning', 'image': 'assets/s4.webp'},
      {'title': 'Balcony & Window Cleaning', 'image': 'assets/s5.webp'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Categories",
            style: TextStyle(
              fontSize: 16.sp * scaleFactor,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12.h * scaleFactor),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20 * scaleFactor,
              crossAxisSpacing: 16 * scaleFactor,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final item = categories[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFFFD9BE),
                    width: 1.w * scaleFactor,
                  ),
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x33E47830),
                      blurRadius: 6 * scaleFactor,
                      offset: Offset(0, 4 * scaleFactor),
                      spreadRadius: -2 * scaleFactor,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.h * scaleFactor,
                    vertical: 12.h * scaleFactor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w * scaleFactor,
                        height: 48.h * scaleFactor,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h * scaleFactor),
                      Text(
                        item['title']!,
                        style: TextStyle(
                          fontSize: 11.5.sp * scaleFactor,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double scaleFactor) {
    return Positioned(
      bottom: 0.r,
      left: 0.r,
      right: 0.r,
      child: Builder(
        builder: (context) {
          final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

          return Container(
            padding: EdgeInsets.fromLTRB(
              16.h * scaleFactor,
              12.h * scaleFactor,
              16.h * scaleFactor,
              ((bottomPadding > 0 ? bottomPadding : 16.h) + 8.h) * scaleFactor,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2 * scaleFactor),
                  blurRadius: 6 * scaleFactor,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "2 items",
                      style: TextStyle(
                        fontSize: 12.sp * scaleFactor,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4.h * scaleFactor),
                    Text(
                      "₹400",
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.h * scaleFactor,
                    vertical: 12.h * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE47830),
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp * scaleFactor,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCards(double scaleFactor) {
    final Map<String, List<Map<String, String>>> groupedServices = {
      'Bathroom Cleaning': [
        {
          'image': 'assets/z2.webp',
          'title': 'Basic Bathroom Cleaning',
          'price': '₹349',
          'rating': '4.78',
          'duration': '30 mins',
        },
        {
          'image': 'assets/z2.webp',
          'title': 'Deep Bathroom Sanitization',
          'price': '₹499',
          'rating': '4.85',
          'duration': '45 mins',
        },
      ],
      'Kitchen Cleaning': [
        {
          'image': 'assets/s1.webp',
          'title': 'Basic Kitchen Cleaning',
          'price': '₹449',
          'rating': '4.76',
          'duration': '40 mins',
        },
        {
          'image': 'assets/s1.webp',
          'title': 'Deep Kitchen Degreasing',
          'price': '₹649',
          'rating': '4.81',
          'duration': '60 mins',
        },
      ],
      'Sofa & Carpet Cleaning': [
        {
          'image': 'assets/s2.webp',
          'title': 'Sofa Shampooing (5 Seater)',
          'price': '₹799',
          'originalPrice': '₹999',
          'rating': '4.84',
          'duration': '60 mins',
          'desc': '• Removes stains & odor\n• Foam-based cleaning\n• Ideal for fabric sofas',
        },
        {
          'image': 'assets/s2.webp',
          'title': 'Carpet Vacuum & Wash ',
          'price': '₹20/sq.ft',
          'originalPrice': '₹30/sq.ft',
          'rating': '4.79',
          'duration': 'Variable',
          'desc': '• Deep vacuuming\n• Steam and shampoo wash\n• Effective dust removal',
        },
      ],
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedServices.entries.map((entry) {
          final String category = entry.key;
          final List<Map<String, String>> services = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 16.sp * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h * scaleFactor),
              ...services.map((service) {
                if (!category.toLowerCase().contains('sofa')) {
                  // Regular service cards with ADD button
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.r * scaleFactor),
                    padding: EdgeInsets.all(12.r * scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 10 * scaleFactor,
                          offset: Offset(0, 4 * scaleFactor),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8 * scaleFactor),
                          child: Image.asset(
                            service['image']!,
                            width: 60.w * scaleFactor,
                            height: 60.h * scaleFactor,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12.w * scaleFactor),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service['title']!,
                                style: TextStyle(
                                  fontSize: 14.sp * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h * scaleFactor),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/star.svg',
                                    width: 18.w * scaleFactor,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 4.w * scaleFactor),
                                  Text(
                                    "${service['rating']} | ${service['duration']}",
                                    style: TextStyle(
                                      fontSize: 12.sp * scaleFactor,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h * scaleFactor),
                              Text(
                                service['price']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp * scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 75.w * scaleFactor,
                          height: 29.h * scaleFactor,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0.r,
                                top: 0.r,
                                child: Container(
                                  width: 75.w * scaleFactor,
                                  height: 29.h * scaleFactor,
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8 * scaleFactor),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: const Color(0x33000000),
                                        blurRadius: 4 * scaleFactor,
                                        offset: Offset(0, 1 * scaleFactor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 32.r * scaleFactor,
                                top: 5.38.r * scaleFactor,
                                child: Text(
                                  'Add',
                                  style: TextStyle(
                                    color: const Color(0xFFE47830),
                                    fontSize: 14.sp * scaleFactor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16.r * scaleFactor,
                                top: 9.r * scaleFactor,
                                child: SizedBox(
                                  width: 12.w * scaleFactor,
                                  height: 12.h * scaleFactor,
                                  child: Icon(
                                    Icons.add,
                                    size: 12 * scaleFactor,
                                    color: const Color(0xFFE47830),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Sofa & Carpet Cleaning with full image and detailed layout
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.r * scaleFactor),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scaleFactor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.05),
                          blurRadius: 10 * scaleFactor,
                          offset: Offset(0, 4 * scaleFactor),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12.h * scaleFactor),
                          ),
                          child: Image.asset(
                            service['image']!,
                            width: double.infinity,
                            height: 180.h * scaleFactor,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.r * scaleFactor),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Add button in same row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    service['title']!,
                                    style: TextStyle(
                                      fontSize: 15.sp * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    width: 75.w * scaleFactor,
                                    height: 29.h * scaleFactor,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0.r,
                                          top: 0.r,
                                          child: Container(
                                            width: 75.w * scaleFactor,
                                            height: 29.h * scaleFactor,
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8 * scaleFactor),
                                              ),
                                              shadows: [
                                                BoxShadow(
                                                  color: const Color(0x33000000),
                                                  blurRadius: 4 * scaleFactor,
                                                  offset: Offset(0, 1 * scaleFactor),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 32.r * scaleFactor,
                                          top: 5.38.r * scaleFactor,
                                          child: Text(
                                            'Add',
                                            style: TextStyle(
                                              color: const Color(0xFFE47830),
                                              fontSize: 14.sp * scaleFactor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 16.r * scaleFactor,
                                          top: 9.r * scaleFactor,
                                          child: SizedBox(
                                            width: 12.w * scaleFactor,
                                            height: 12.h * scaleFactor,
                                            child: Icon(
                                              Icons.add,
                                              size: 12 * scaleFactor,
                                              color: const Color(0xFFE47830),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h * scaleFactor),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/star.svg',
                                    width: 18.w * scaleFactor,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 4.w * scaleFactor),
                                  Text(
                                    "${service['rating']} | ${service['duration']}",
                                    style: TextStyle(
                                      fontSize: 12.sp * scaleFactor,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h * scaleFactor),
                              Row(
                                children: [
                                  Text(
                                    service['price']!,
                                    style: TextStyle(
                                      fontSize: 16.sp * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 6.w * scaleFactor),
                                  Text(
                                    service['originalPrice']!,
                                    style: TextStyle(
                                      fontSize: 14.sp * scaleFactor,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (service['desc'] != null && service['desc']!.isNotEmpty) ...[
                                SizedBox(height: 8.h * scaleFactor),
                                Text(
                                  service['desc']!,
                                  style: TextStyle(
                                    fontSize: 12.sp * scaleFactor,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
