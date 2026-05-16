import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/core/theme/theme.dart';
import '../../../../core/routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate some initialization time
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      context.go(RouteNames.getLoginPath());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:255*0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            // App Name
            Text(
              'Rice Yield Predictor',
              style: AppTheme.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Smart Agriculture Solutions',
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha:255*0.8),
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            // Loading Text
            Text(
              'Loading...',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha:255*0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}