import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'views/splash/splash_screen.dart';
import 'widgets/OnboardingScreen.dart';
import 'views/login/login_screen.dart';
import 'views/login/otp_verification_screen.dart';
import 'views/home/home_screen.dart';

void main() {
  runApp(const ChayanKaroApp());
}

class ChayanKaroApp extends StatelessWidget {
  const ChayanKaroApp({super.key});

  bool _isTablet(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final widthDp = size.width;
    final heightDp = size.height;
    final diagonalDp = sqrt(pow(widthDp, 2) + pow(heightDp, 2));

    final isLargeEnough = diagonalDp >= 1100; // ~7" at mdpi
    final isWideEnough = size.shortestSide >= 500;

    // Debug logs
    debugPrint(
      '[Device Check] widthDp: $widthDp, heightDp: $heightDp, diagonalDp: $diagonalDp, '
      'isLargeEnough: $isLargeEnough, isWideEnough: $isWideEnough, '
      'detectedTablet: ${isLargeEnough || isWideEnough}',
    );

    return isLargeEnough || isWideEnough;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ChayanKaro',
          theme: ThemeData(
            fontFamily: 'SFPro',
            primaryColor: const Color(0xFFFF6F00),
            scaffoldBackgroundColor: Colors.white,
          ),
          builder: (context, widget) {
            final mediaQuery = MediaQuery.of(context);
            final isTablet = _isTablet(mediaQuery);

            // Dynamically scale for tablets
            final designSize = isTablet
                ? Size(
                    mediaQuery.size.shortestSide,
                    mediaQuery.size.longestSide,
                  )
                : const Size(390, 844);

            return ScreenUtilInit(
              designSize: designSize,
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, __) {
                return MediaQuery(
                  data: mediaQuery.copyWith(textScaleFactor: 1.0),
                  child: widget!,
                );
              },
            );
          },
          initialRoute: '/',
          routes: {
            '/': (_) => SplashScreen(),
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => LoginScreen(),
            '/otp': (_) => OtpVerificationScreen(),
            '/home': (_) => const HomeScreen(),
          },
        );
      },
    );
  }
}
