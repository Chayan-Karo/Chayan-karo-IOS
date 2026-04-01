import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../data/local/database.dart';
import '../../services/notification_service.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
   //final NotificationService _notificationService;


  @override
  void initState() {
    super.initState();
    // 🔥 INIT FCM ON APP START
  //_notificationService = NotificationService();
  //_notificationService.init();
  NotificationService().init();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    // ✨ Navigate after GIF animation completes
    Future.delayed(const Duration(milliseconds: 4200), () {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await _navigateToCorrectScreen();
        }
      });
    });
  }

  // ✨ Simplified navigation logic: auth + onboarding only
 /// 🎯 Refactored Guest Mode + Auth Flow Logic
  Future<void> _navigateToCorrectScreen() async {
    try {
      final database = Get.find<AppDatabase>();

      // Fetch all status flags
      final bool hasSeenOnboarding = await database.hasSeenOnboarding();
      final bool hasEnteredApp = await database.hasEnteredApp(); // New Flag
      final bool isLoggedIn = await database.isUserLoggedIn();
      final bool isSessionValid = await database.isSessionValid();

      print('🔐 Splash: Onboarding=$hasSeenOnboarding, Entered=$hasEnteredApp, LoggedIn=$isLoggedIn');

      // 1️⃣ Priority: Mandatory Onboarding for new installs
      if (!hasSeenOnboarding) {
        print('🆕 Splash: Brand new user - showing onboarding');
        Get.offAllNamed('/onboarding');
        return;
      }

      // 2️⃣ Priority: Valid Session - Go Home (Logged-in Mode)
      if (isLoggedIn && isSessionValid) {
        print('✅ Splash: Auth OK - Going Home');
        Get.offAllNamed('/home');
        return;
      }

      // 3️⃣ Priority: Guest Mode Check (The "Skip" Logic)
      // If they have "Entered App" once (via Skip or previous login), 
      // even if logged out or session expired, they go straight to Home.
      if (hasEnteredApp) {
        print('🏠 Splash: Guest Mode active - Going Home');
        
        // Cleanup expired session data quietly if needed
        if (isLoggedIn && !isSessionValid) {
          await database.clearAuthData();
        }
        
        Get.offAllNamed('/home');
        return;
      }

      // 4️⃣ Default: First time seeing the Login screen after Onboarding
      print('🔑 Splash: User must see login screen for the first time');
      Get.offAllNamed('/login');

    } catch (e, stack) {
      print('❌ Splash: Fatal error determining route: $e');
      print(stack);
      Get.offAllNamed('/onboarding'); // Safe fallback
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/chayankaro_logo.gif',
            width: screenWidth * 0.8.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
