import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/database.dart';
import '../../services/notification_service.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<String> _routeFuture;

  @override
  void initState() {
    super.initState();

    NotificationService().init();

    // 🔥 Start logic immediately
    _routeFuture = _decideRoute();

    _handleNavigation();
  }

  /// 🎯 ONLY decides route (no navigation here)
  Future<String> _decideRoute() async {
    try {
      final database = Get.find<AppDatabase>();

      final hasSeenOnboarding = await database.hasSeenOnboarding();
      final hasEnteredApp = await database.hasEnteredApp();
      final isLoggedIn = await database.isUserLoggedIn();
      final isSessionValid = await database.isSessionValid();

      if (!hasSeenOnboarding) return '/onboarding';

      if (isLoggedIn && isSessionValid) return '/home';

      if (hasEnteredApp) {
        if (isLoggedIn && !isSessionValid) {
          await database.clearAuthData();
        }
        return '/home';
      }

      return '/login';
    } catch (_) {
      return '/onboarding';
    }
  }

  /// 🚀 Navigation handler (smooth UX)
  void _handleNavigation() async {
    final route = await _routeFuture;

    // Small delay to avoid abrupt transition (VERY IMPORTANT)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Get.offAllNamed(route);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F5),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/icons/croplogo.png', // 🔥 MUST match the native image
            // On Android 12, the system scales the icon to 160-190 logical pixels.
            // Try 170 first. If it's still slightly off, adjust by 5px.
            width: 172, 
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),
  );
}
}