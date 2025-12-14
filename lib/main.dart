import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'views/booking/feedback_screen.dart';
// Screens
import 'views/splash/splash_screen.dart';
import 'widgets/OnboardingScreen.dart';
import 'views/login/login_screen.dart';
import 'views/login/otp_verification_screen.dart';
import 'views/home/home_screen.dart';
import 'views/cart/cart_screen.dart';
import 'widgets/location_popup_screen.dart';
import 'views/profile/profile_screen.dart';
import 'widgets/choose_location_sheet.dart';
import 'widgets/service_area_info_screen.dart';
import 'views/booking/PaymentSuccess.dart';
import 'views/booking/payment_failed_screen.dart';
import 'views/profile/EditProfileScreen.dart';

// Dependencies
import 'di/app_binding.dart';
import 'data/local/database.dart';
import 'data/repository/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  await initializeDependencies();

  runApp(const ChayanKaroApp());
}

Future<void> initializeDependencies() async {
  AppBinding().dependencies();

  try {
    final db = Get.find<AppDatabase>();
    final repo = CategoryRepository();
    print(await db.getDatabaseStats());
  } catch (e) {
    print("Dependency failed: $e");
  }
}

// =======================================================
// APP ROOT
// =======================================================
class ChayanKaroApp extends StatelessWidget {
  const ChayanKaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        final mediaQuery = MediaQueryData.fromView(view);

        final designSize = DesignSizeHelper.getDesignSize(mediaQuery);

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: "ChayanKaro",

              // FIX: Samsung resize & keyboard UI shift
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,   // Prevents UI from breaking on Samsung
                  ),
                  child: widget!,
                );
              },

              theme: ThemeData(
                useMaterial3: false,
                fontFamily: "SFPro",
                scaffoldBackgroundColor: Colors.white,
              ),

              initialBinding: AppBinding(),
              initialRoute: '/',

              getPages: [
                GetPage(name: '/', page: () => const SplashScreen()),
                GetPage(name: '/onboarding', page: () => const OnboardingScreen()),

                GetPage(name: '/login', page: () => const LoginScreen()),
                GetPage(name: '/otp', page: () => const OtpVerificationScreen()),

                GetPage(name: '/home', page: () => const HomeScreen()),
                GetPage(name: '/profile', page: () => const ProfileScreen()),
                GetPage(name: '/cart', page: () => CartScreen()),

                GetPage(name: '/location_popup', page: () => const LocationPopupScreen()),
                GetPage(name: '/choice', page: () => const ChooseLocationSheet()),
                GetPage(name: '/service_area_info', page: () => const ServiceAreaInfoScreen()),

                GetPage(name: '/payment-success', page: () => const PaymentSuccessScreen()),
                GetPage(name: '/payment-failed', page: () => const PaymentFailedScreen()),
                GetPage(name: '/feedback_screen', page: () => const FeedbackScreen()),


              GetPage(
                  name: '/edit-profile',
                  page: () => EditProfileScreen(customer: Get.arguments),
                ),
              ],

              unknownRoute: GetPage(
                name: '/notfound',
                page: () => Scaffold(
                  appBar: AppBar(title: const Text("Page Not Found")),
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed('/'),
                      child: const Text("Go Home"),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// =======================================================
// DEVICE SIZE HELPER — UNIVERSAL FIX
// =======================================================
class DesignSizeHelper {
  static Size getDesignSize(MediaQueryData mq) {
    final size = mq.size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    final isTablet = diagonal >= 1100 || size.shortestSide >= 500;

    // 📌 UNIVERSAL FIX
    // Always use **390×844** for all phones (Samsung, Poco, old devices)
    // Only tablets will scale differently.
    if (!isTablet) {
      return const Size(390, 844);
    }

    // Tablet sizes
    if (max(size.width, size.height) >= 1400) {
      return size.width > size.height
          ? const Size(1366, 1024)
          : const Size(1024, 1366);
    }

    return size.width > size.height
        ? const Size(960, 600)
        : const Size(600, 960);
  }
}
