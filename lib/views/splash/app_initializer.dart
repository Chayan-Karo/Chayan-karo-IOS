import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/database.dart';
import '../../services/notification_service.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer>
    with SingleTickerProviderStateMixin {
  late Future<String> _routeFuture;

  // 🔥 Premium Quotes
  final List<String> _quotes = [
    "Comfort, just a tap away.",
    "Making your home feel complete.",
    "Care your home deserves.",
    "Relax. We’ve got this.",
    "Your home, our responsibility.",
    "Beauty that comes to you.",
    "Glow without stepping out.",
    "Salon care, at your comfort.",
    "Because you deserve self-care.",
    "Look good, feel better.",
    "Book it. Done.",
    "No hassle. Just service.",
    "Easy booking. Expert service.",
    "From tap to done.",
    "Service made simple.",
    "Experts you can rely on.",
    "Trusted hands, every time.",
    "Professional care at home.",
    "We treat your home like ours.",
    "Service you can trust.",
    "Redefining home services.",
    "Elevating everyday living.",
    "Experience better service.",
    "Designed for your comfort.",
    "Service, reimagined.",
  ];

  int _currentIndex = 0;
  Timer? _quoteTimer;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    NotificationService().init();

    // 🔥 Logic untouched
    _routeFuture = _decideRoute();
    _handleNavigation();

    // 🎯 Shuffle quotes
    _quotes.shuffle();

    // ✨ Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // 🔁 Slower rotation (readable)
    _quoteTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!mounted) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % _quotes.length;
      });

      _controller.reset();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  /// 🎯 Logic unchanged
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

  /// 🚀 Navigation unchanged
  void _handleNavigation() async {
    final route = await _routeFuture;

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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),

            /// 🔥 LOGO
            Image.asset(
              'assets/icons/splash_logo.png',
              width: 170,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 36),

            /// ✨ Animated Quote
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _quotes[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const Spacer(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}