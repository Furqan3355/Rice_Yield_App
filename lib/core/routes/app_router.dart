import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/features/auth/presentation/login_screen.dart';
import 'package:rice_yield_app/features/auth/presentation/signup_screen.dart';
import '../../features/home/presentation/home_wrapper.dart';
import '../../features/home/presentation/home_screen.dart';
import 'package:rice_yield_app/features/upload/presentation/upload_screen.dart';
import 'package:rice_yield_app/features/reports/presentation/reports_history_screen.dart';
import 'package:rice_yield_app/features/profile/presentation/profile_screen.dart';
import 'package:rice_yield_app/features/profile/presentation/privacy_policy_screen.dart';
import 'package:rice_yield_app/features/profile/presentation/help_support_screen.dart';
import 'dart:async';

class AppRouter {
  final Ref ref;
  AppRouter({required this.ref});

  GoRouter get router => GoRouter(
        initialLocation: ref.read(initialRouteProvider),
        refreshListenable:
            _RouterRefreshStream(ref.watch(authNotifierProvider.notifier).stream),
        redirect: (context, state) {
          final authState = ref.read(authNotifierProvider);
          final loc = state.matchedLocation;

          if (!authState.isInitialized) return null;

          if (loc == '/') {
            return authState.isAuthenticated ? '/home' : '/login';
          }

          final isAuthPage = loc == '/login' || loc == '/signup';
          if (!authState.isAuthenticated && !isAuthPage) return '/login';
          if (authState.isAuthenticated && isAuthPage) return '/home';

          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
          GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
          ShellRoute(
            builder: (context, state, child) => HomeWrapper(child: child),
            routes: [
              GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
              GoRoute(path: '/upload', builder: (c, s) => const UploadScreen()),
              GoRoute(
                path: '/history',
                builder: (c, s) => const ReportsHistoryScreen(),
              ),
              GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
              GoRoute(
                path: '/privacy',
                builder: (c, s) => const PrivacyPolicyScreen(),
              ),
              GoRoute(
                path: '/help',
                builder: (c, s) => const HelpSupportScreen(),
              ),
            ],
          ),
        ],
      );
}

class _RouterRefreshStream extends ChangeNotifier {
  _RouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
