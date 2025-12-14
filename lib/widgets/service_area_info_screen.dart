// lib/views/location/service_area_info_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceAreaInfoScreen extends StatelessWidget {
  const ServiceAreaInfoScreen({super.key});

  static const Color appOrange = Color(0xFFE47830);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Service availability',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_2_rounded, size: 88, color: appOrange),
                const SizedBox(height: 24),
                Text(
                  'No service at this location',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Currently available only in Lucknow.\nPlease pick a location from Lucknow to continue.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final res = await Get.toNamed('/location_popup', arguments: {
                        'source': 'service_area_info',
                        'mode': 'instant_current',
                      });
                      if (res != null) Get.back(result: res);
                    },
                    child: const Text('Choose Lucknow location', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final res = await Get.toNamed('/location_popup', arguments: {
                      'source': 'service_area_info',
                    });
                    if (res != null) Get.back(result: res);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: appOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Go back to location selection'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(height: 12 + MediaQuery.of(context).padding.bottom),
    );
  }
}
