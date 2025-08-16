import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';

import 'views/splash/splash_screen.dart';
import 'widgets/OnboardingScreen.dart';
import 'views/login/login_screen.dart';
import 'views/login/otp_verification_screen.dart';
import 'views/home/home_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Set to false in production
      builder: (context) => const ChayanKaroApp(),
    ),
  );
}

class ChayanKaroApp extends StatelessWidget {
  const ChayanKaroApp({super.key});

  static const bool kEnableDeviceLogs = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final mediaQuery = MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        );

        final designSize = DesignSizeHelper.getDesignSize(mediaQuery);

        if (kEnableDeviceLogs) {
          DesignSizeHelper.logDeviceInfo(mediaQuery);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(
            useInheritedMediaQuery: true,
            debugShowCheckedModeBanner: false,
            title: 'ChayanKaro',
            theme: ThemeData(
              fontFamily: 'SFPro',
              primaryColor: const Color(0xFFFF6F00),
              scaffoldBackgroundColor: Colors.white,
            ),
            builder: DevicePreview.appBuilder,
            initialRoute: '/',
            routes: {
              '/': (_) => SplashScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/login': (_) => LoginScreen(),
              '/otp': (_) => OtpVerificationScreen(),
              '/home': (_) => const HomeScreen(),
            },
          ),
        );
      },
    );
  }
}

class DesignSizeHelper {
  static Size getDesignSize(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final diagonalDp = sqrt(pow(size.width, 2) + pow(size.height, 2));

    final bool isTablet =
        diagonalDp >= 1100 || size.shortestSide >= 500; // Main tablet check

    final bool isLargeTablet = isTablet && max(size.width, size.height) >= 1400;
    final bool isLandscape = size.width > size.height;

    // PHONE baseline — iPhone 13 dimensions
    const phoneSize = Size(390, 844);

    if (!isTablet) {
      return phoneSize;
    }

    // TABLET baseline scaling
    if (isLargeTablet) {
      // Large tablet like iPad Pro — still scale from phone ratio
      return isLandscape ? const Size(1366, 1024) : const Size(1024, 1366);
    } else {
      // Medium/small tablets & foldable inner display
      return isLandscape ? const Size(960, 600) : const Size(600, 960);
    }
  }

  static void logDeviceInfo(MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final diagonalDp = sqrt(pow(size.width, 2) + pow(size.height, 2));
    final bool isTablet =
        diagonalDp >= 1100 || size.shortestSide >= 500;
    final bool isLargeTablet = isTablet && max(size.width, size.height) >= 1400;

    debugPrint(
      '[Device Check] widthDp: ${size.width}, heightDp: ${size.height}, '
      'diagonalDp: ${diagonalDp.toStringAsFixed(2)}, '
      'isTablet: $isTablet, isLargeTablet: $isLargeTablet',
    );
  }
}
