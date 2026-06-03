import 'package:flutter/material.dart';
import '../features/splash_screen/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/main/main_screen.dart';
import '../features/map/nearby_services_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String nearby = '/nearby';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    main: (context) => const MainScreen(),
    nearby: (context) => const NearbyServicesScreen(),
  };
}
