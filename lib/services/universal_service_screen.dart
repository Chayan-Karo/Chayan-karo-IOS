// screens/category_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/category_models.dart';
import '../models/service_models.dart';
import '../views/cart/cart_screen.dart';
import '../views/booking/Summaryscreen.dart';

class CategoryServiceScreen extends StatefulWidget {
  final Category category; // Now takes the main Category
  final String? scrollToServiceCategoryId;

  const CategoryServiceScreen({
    Key? key,
    required this.category,
    this.scrollToServiceCategoryId,
  }) : super(key: key);

  @override
  State<CategoryServiceScreen> createState() => _CategoryServiceScreenState();
}

class _CategoryServiceScreenState extends State<CategoryServiceScreen> {
  final ScrollController _scrollController = ScrollController();
  late ServiceController serviceController;
  late CartController cartController;

  // Track services that show increment/decrement controls on this page session
  final RxSet<String> _currentPageInteractedServices = <String>{}.obs;
  // Track services selected on this page only
  final RxList<String> _currentPageSelectedServices = <String>[].obs;

  // Dynamic category keys for scrolling
  final Map<String, GlobalKey> _serviceCategoryKeys = {};

  // Store services for each service category
  final RxMap<String, List<Service>> _servicesByCategory = <String, List<Service>>{}.obs;
  final RxMap<String, bool> _loadingByCategory = <String, bool>{}.obs;
  final RxMap<String, bool> _errorByCategory = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    serviceController = Get.find<ServiceController>();
    cartController = Get.find<CartController>();

    print('🟢 CategoryServiceScreen initialized for ${widget.category.categoryName}');

    // Initialize keys for each service category
    for (var serviceCategory in widget.category.serviceCategory) {
      _serviceCategoryKeys[serviceCategory.serviceCategoryId] = GlobalKey();
    }

    _loadAllServices();
  }

  void _loadAllServices() async {
    // Load services for each service category
    for (var serviceCategory in widget.category.serviceCategory) {
      _loadServicesForCategory(serviceCategory.serviceCategoryId);
    }

    // Auto-scroll to specific service category if provided
    if (widget.scrollToServiceCategoryId != null) {
      _scrollToServiceCategory(widget.scrollToServiceCategoryId!);
    }
  }

  void _loadServicesForCategory(String serviceCategoryId) async {
    _loadingByCategory[serviceCategoryId] = true;
    _errorByCategory[serviceCategoryId] = false;

    try {
      print('🔄 Loading services for service category: $serviceCategoryId');

      // Use the service controller to load services
      await serviceController.loadServices(serviceCategoryId);

      // Store the services for this category
      _servicesByCategory[serviceCategoryId] = List.from(serviceController.services);

      print('✅ Loaded ${serviceController.services.length} services for category $serviceCategoryId');
    } catch (e) {
      print('❌ Error loading services for category $serviceCategoryId: $e');
      _errorByCategory[serviceCategoryId] = true;
    } finally {
      _loadingByCategory[serviceCategoryId] = false;
    }
  }

  void _scrollToServiceCategory(String serviceCategoryId) {
    Future.delayed(Duration(milliseconds: 500), () {
      final key = _serviceCategoryKeys[serviceCategoryId];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  // Add to cart with source information
  void _addToCart(Service service) {
    cartController.addServiceToCart(
      service,
      sourcePage: 'category_service_${widget.category.categoryId}',
      sourceTitle: widget.category.categoryName,
    );
    _currentPageInteractedServices.add(service.id);
    if (!_currentPageSelectedServices.contains(service.id)) {
      _currentPageSelectedServices.add(service.id);
    }
  }

  void _incrementCart(String serviceId) {
    cartController.incrementQuantity(serviceId);
    if (!_currentPageSelectedServices.contains(serviceId)) {
      _currentPageSelectedServices.add(serviceId);
    }
  }

  void _decrementCart(String serviceId) {
    cartController.decrementQuantity(serviceId);
    if (cartController.getQuantity(serviceId) == 0) {
      _currentPageSelectedServices.remove(serviceId);
      _currentPageInteractedServices.remove(serviceId);
    }
  }

  bool get _hasCurrentPageSelections {
    return _currentPageSelectedServices.isNotEmpty &&
        _currentPageSelectedServices.any((serviceId) => cartController.getQuantity(serviceId) > 0);
  }

  double get _currentPageTotal {
    double total = 0;
    for (String serviceId in _currentPageSelectedServices) {
      final quantity = cartController.getQuantity(serviceId);
      if (quantity > 0) {
        // Find service across all categories
        Service? service;
        for (var serviceList in _servicesByCategory.values) {
          service = serviceList.firstWhereOrNull((s) => s.id == serviceId);
          if (service != null) break;
        }
        if (service != null) {
          total += service.discountedPrice * quantity;
        }
      }
    }
    return total;
  }

  int get _currentPageItemCount {
    int count = 0;
    for (String serviceId in _currentPageSelectedServices) {
      count += cartController.getQuantity(serviceId);
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xFFFFEEE0),
      statusBarIconBrightness: Brightness.dark,
    ));

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final double scaleFactor = isTablet ? constraints.maxWidth / 411 : 1.0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 74.r * scaleFactor + MediaQuery.of(context).padding.top),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h * scaleFactor),
                          _buildTopBanner(scaleFactor),
                          SizedBox(height: 12.h * scaleFactor),
                          _buildCategoryInfoBlock(scaleFactor),
                          SizedBox(height: 16.h * scaleFactor),
                          _buildDiscountCards(scaleFactor),
                          SizedBox(height: 16.h * scaleFactor),
                          _buildCustomPackageSection(scaleFactor),
                          SizedBox(height: 16.h * scaleFactor),
                          _buildServiceCategoryGrid(scaleFactor),
                          SizedBox(height: 16.h * scaleFactor),
                          _buildServiceCategorySections(scaleFactor),
                          Obx(() => _hasCurrentPageSelections
                              ? SizedBox(height: 100.h * scaleFactor)
                              : SizedBox(height: 16.h * scaleFactor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              Obx(() => _hasCurrentPageSelections ? _buildBottomBar(scaleFactor) : SizedBox()),
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
                widget.category.categoryName,
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
            // Cart icon (SVG like salon screen)
            Obx(() => GestureDetector(
                  onTap: () {
                    // Navigate to CartScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/cart.svg',
                        width: 40.w * scaleFactor,
                        height: 40.h * scaleFactor,
                        color: Colors.black,
                      ),
                      if (cartController.cartItemCount > 0)
                        Positioned(
                          right: -2 * scaleFactor,
                          top: -2 * scaleFactor,
                          child: Container(
                            padding: EdgeInsets.all(4 * scaleFactor),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10 * scaleFactor),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 18 * scaleFactor,
                              minHeight: 18 * scaleFactor,
                            ),
                            child: Text(
                              '${cartController.cartItemCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp * scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
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
            // background image (same asset usage as salon screen — here category provides image URL)
            Image.network(
              widget.category.imgLink,
              width: double.infinity,
              height: 160.h * scaleFactor,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 160.h * scaleFactor,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.category,
                    size: 48 * scaleFactor,
                    color: const Color(0xFFFF6F00),
                  ),
                );
              },
            ),

            // subtle gradient overlay to match salon look
            Container(
              width: double.infinity,
              height: 160.h * scaleFactor,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.35),
                  ],
                ),
              ),
            ),

            // white rounded chip (matches salon style)
            Positioned(
              bottom: 12.r * scaleFactor,
              left: 12.r * scaleFactor,
             child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.h * scaleFactor, 
                  vertical: 6.h * scaleFactor
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20 * scaleFactor),
                ),
                child: Text(
                  widget.category.categoryName,
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp * scaleFactor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInfoBlock(double scaleFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.category.categoryName,
                  style: TextStyle(
                    fontSize: 16.sp * scaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
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
                    SizedBox(width: 6.w * scaleFactor),
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
              SvgPicture.asset('assets/icons/star.svg',
                  width: 18.w * scaleFactor, height: 18.h * scaleFactor, color: Colors.black),
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
                child: SvgPicture.asset('assets/icons/tick.svg', color: Colors.black),
              ),
              SizedBox(width: 6.w * scaleFactor),
              Text(
                "${widget.category.serviceCategory.length} service categories available",
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6 * scaleFactor,
                  offset: Offset(0, 2 * scaleFactor),
                ),
              ],
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
          gradient: LinearGradient(
            colors: [Color(0xFFE47830), Color(0xFFFA9441)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          boxShadow: [
            BoxShadow(
              color: Color(0x33E47830),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
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
                      child: Text(
                        'Create a Custom Package',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp * scaleFactor,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h * scaleFactor),
                    SizedBox(
                      width: 156.31.w * scaleFactor,
                      child: Opacity(
                        opacity: 0.50,
                        child: Text(
                          'Specifically for your needs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp * scaleFactor,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
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

  Widget _buildServiceCategoryGrid(double scaleFactor) {
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
            itemCount: widget.category.serviceCategory.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20 * scaleFactor,
              crossAxisSpacing: 16 * scaleFactor,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (context, index) {
              final serviceCategory = widget.category.serviceCategory[index];
              return GestureDetector(
                onTap: () => _scrollToServiceCategory(serviceCategory.serviceCategoryId),
                child: Container(
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
                            child: Image.network(
                              serviceCategory.imgLink,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.home_repair_service,
                                  color: const Color(0xFFFF6F00),
                                  size: 24 * scaleFactor,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h * scaleFactor),
                        Text(
                          serviceCategory.serviceCategoryName,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategorySections(double scaleFactor) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.category.serviceCategory.map((serviceCategory) {
            return Container(
              key: _serviceCategoryKeys[serviceCategory.serviceCategoryId],
              margin: EdgeInsets.only(bottom: 24.h * scaleFactor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceCategory.serviceCategoryName,
                    style: TextStyle(
                      fontSize: 16.sp * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12.h * scaleFactor),
                  _buildServicesForCategory(serviceCategory, scaleFactor),
                ],
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildServicesForCategory(ServiceSubCategory serviceCategory, double scaleFactor) {
    final serviceCategoryId = serviceCategory.serviceCategoryId;
    final isLoading = _loadingByCategory[serviceCategoryId] ?? true;
    final hasError = _errorByCategory[serviceCategoryId] ?? false;
    final services = _servicesByCategory[serviceCategoryId] ?? [];

    if (isLoading && services.isEmpty) {
      return Container(
        height: 100.h * scaleFactor,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF6F00)),
        ),
      );
    }

    if (hasError && services.isEmpty) {
      return Container(
        height: 100.h * scaleFactor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(height: 4.h * scaleFactor),
              Text(
                'Failed to load services',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp * scaleFactor,
                ),
              ),
              SizedBox(height: 4.h * scaleFactor),
              ElevatedButton(
                onPressed: () => _loadServicesForCategory(serviceCategoryId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6F00),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (services.isEmpty) {
      return Container(
        height: 60.h * scaleFactor,
        child: Center(
          child: Text(
            'No services available',
            style: TextStyle(color: Colors.grey, fontSize: 12.sp * scaleFactor),
          ),
        ),
      );
    }

    return Column(
      children: services.map((service) => _buildServiceCard(service, scaleFactor)).toList(),
    );
  }

Widget _buildServiceCard(Service service, double scaleFactor) {
  final RxBool isExpanded = false.obs;

  return Obx(() => Container(
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8 * scaleFactor),
                  child: Image.network(
                    service.imgLink,
                    width: 70.w * scaleFactor,
                    height: 70.h * scaleFactor,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70.w * scaleFactor,
                      height: 70.h * scaleFactor,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 30 * scaleFactor),
                    ),
                  ),
                ),
                SizedBox(width: 12.w * scaleFactor),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name + arrow with forced line break
                      GestureDetector(
                        onTap: () => isExpanded.toggle(),
                        behavior: HitTestBehavior.translucent,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return _buildSmartServiceName(service.name, isExpanded, scaleFactor, constraints.maxWidth);
                          },
                        ),
                      ),

                      SizedBox(height: 4.h * scaleFactor),

                      // Rating + duration
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/star.svg',
                              width: 16.w * scaleFactor,
                              height: 16.h * scaleFactor,
                              color: Colors.black),
                          SizedBox(width: 4.w * scaleFactor),
                          Text(
                            "${service.rating} | ${service.formattedDuration}",
                            style: TextStyle(
                              fontSize: 12.sp * scaleFactor,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.h * scaleFactor),

                      // Price
                      Text(
                        service.formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp * scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity selector
                _buildQuantitySelector(service, scaleFactor),
              ],
            ),

            // Expandable description
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: service.description.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: 8.h * scaleFactor,
                          left: 4.w * scaleFactor,
                          right: 4.w * scaleFactor),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          service.description,
                          style: TextStyle(
                            fontSize: 12.sp * scaleFactor,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              crossFadeState: isExpanded.value
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ));
}

Widget _buildSmartServiceName(String serviceName, RxBool isExpanded, double scaleFactor, double availableWidth) {
  final words = serviceName.split(' ');
  final textStyle = TextStyle(
    fontSize: 14.sp * scaleFactor,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  
  // For services with 3+ words, check if we should force a line break
  if (words.length >= 3) {
    // Calculate width of full text + arrow
    final fullTextPainter = TextPainter(
      text: TextSpan(text: serviceName, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    fullTextPainter.layout();
    
    final arrowWidth = 28 * scaleFactor; // Arrow + padding
    final totalWidth = fullTextPainter.width + arrowWidth;
    
    // If text + arrow is close to or exceeds available width (80% threshold)
    if (totalWidth > availableWidth * 0.8) {
      // Force break: move last word to next line with arrow
      final firstPart = words.sublist(0, words.length - 1).join(' ');
      final lastWord = words.last;
      
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(text: firstPart, style: textStyle),
            TextSpan(text: '\n$lastWord', style: textStyle),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 4.w * scaleFactor),
                child: AnimatedRotation(
                  turns: isExpanded.value ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20 * scaleFactor,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  
  // Default: no forced line break
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(text: serviceName, style: textStyle),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(left: 4.w * scaleFactor),
            child: AnimatedRotation(
              turns: isExpanded.value ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20 * scaleFactor,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}





  Widget _buildQuantitySelector(Service service, double scaleFactor) {
    return Obx(() {
      final quantity = cartController.getQuantity(service.id);
      final hasInteractedOnThisPage = _currentPageInteractedServices.contains(service.id);

      if (quantity == 0 || !hasInteractedOnThisPage) {
        return GestureDetector(
          onTap: () => _addToCart(service),
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
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 12 * scaleFactor,
                  color: Color(0xFFE47830),
                ),
                SizedBox(width: 4.w * scaleFactor),
                Text(
                  'Add',
                  style: TextStyle(
                    color: Color(0xFFE47830),
                    fontSize: 14.sp * scaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return Container(
          width: 85.w * scaleFactor,
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
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () => _decrementCart(service.id),
                child: Icon(
                  Icons.remove,
                  size: 14 * scaleFactor,
                  color: Color(0xFFE47830),
                ),
              ),
              Text(
                '$quantity',
                style: TextStyle(
                  color: Color(0xFFE47830),
                  fontSize: 14.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _incrementCart(service.id),
                child: Icon(
                  Icons.add,
                  size: 14 * scaleFactor,
                  color: Color(0xFFE47830),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  Widget _buildBottomBar(double scaleFactor) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(() {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16.w * scaleFactor,
            16.h * scaleFactor,
            16.w * scaleFactor,
            MediaQuery.of(context).viewPadding.bottom + 16.h * scaleFactor,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, -2 * scaleFactor),
                blurRadius: 8 * scaleFactor,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$_currentPageItemCount items",
                    style: TextStyle(
                      fontSize: 12.sp * scaleFactor,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h * scaleFactor),
                  Text(
                    "₹${_currentPageTotal.toInt()}",
                    style: TextStyle(
                      fontSize: 16.sp * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Buy Now button navigates to SummaryScreen (keeps same parameters as before)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SummaryScreen(
                        currentPageSelectedServices: _currentPageSelectedServices.toList(),
                        initialAddress: 'Static address 123, City XYZ',
                        initialTimeSlot: 'Select time slot',
                        initialSaathi: null,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w * scaleFactor,
                    vertical: 12.h * scaleFactor,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFE47830),
                    borderRadius: BorderRadius.circular(30 * scaleFactor),
                  ),
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp * scaleFactor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
