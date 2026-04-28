import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/category_models.dart';
import '../models/service_models.dart';

class CategoryServiceSearchScreen extends StatefulWidget {
  final Category category;
  final Map<String, List<Service>> servicesByCategory;
  final Function(String serviceId) onServiceSelected;

  const CategoryServiceSearchScreen({
    super.key,
    required this.category,
    required this.servicesByCategory,
    required this.onServiceSelected,
  });

  @override
  State<CategoryServiceSearchScreen> createState() =>
      _CategoryServiceSearchScreenState();
}

class _CategoryServiceSearchScreenState
    extends State<CategoryServiceSearchScreen> {
  final TextEditingController textController = TextEditingController();

  final RxList<Service> results = <Service>[].obs;
  final RxBool isSearching = false.obs;

  late List<Service> allServices;

  @override
  void initState() {
    super.initState();

    // ✅ flatten services
    allServices =
        widget.servicesByCategory.values.expand((e) => e).toList();
  }

  void onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      results.clear();
      return;
    }

    isSearching.value = true;

    results.assignAll(
      allServices.where((s) =>
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.description.toLowerCase().contains(query.toLowerCase())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x9BE47830)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Get.back(),
                    ),

                    Expanded(
                      child: TextField(
                        controller: textController,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search services...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    Obx(() => isSearching.value
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              textController.clear();
                              onSearchChanged('');
                            },
                          )
                        : const SizedBox()),
                  ],
                ),
              ),
            ),

            // RESULTS
            Expanded(
              child: Obx(() {
                if (!isSearching.value) {
                 return Center(
  child: Text(
    "Search services in ${widget.category.categoryName}",
    style: const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    ),
  ),
);
                }

               if (results.isEmpty) {
  return _buildEmptyState(context, 1.0); // scaleFactor = 1 for now
}

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final service = results[index];

                    final original = service.price;
                    final discount = service.discountPercentage;
                    final finalPrice = discount > 0
                        ? (original * (1 - discount / 100))
                        : original;

                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: service.imgLink,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(service.name),
                      subtitle: Text("₹${finalPrice.toInt()}"),
                      onTap: () {
  Get.back();

  Future.delayed(const Duration(milliseconds: 250), () {
    widget.onServiceSelected(service.id);
  });
}
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildEmptyState(BuildContext context, double scaleFactor) {
  return Center(
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w * scaleFactor,
            height: 100.h * scaleFactor,
            decoration: BoxDecoration(
              color: const Color(0xFFE47830).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48.sp * scaleFactor,
              color: const Color(0xFFE47830),
            ),
          ),
          SizedBox(height: 24.h * scaleFactor),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 18.sp * scaleFactor,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h * scaleFactor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w * scaleFactor),
            child: Text(
              'We couldn\'t find any services matching your search in ${widget.category.categoryName}. Try different keywords.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp * scaleFactor,
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro',
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}