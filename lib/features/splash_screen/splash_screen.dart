import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final bool completed = await StorageService().hasCompletedOnboarding();

    if (!mounted) return;

    if (completed) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 100.w, color: Colors.white),
            SizedBox(height: 24.h),
            Text(
              'Emergency SOS',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your Safety Companion',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
