import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/supabase_config.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/storage/auth_storage.dart';
import '/core/theme/theme.dart';
import 'package:flutter/services.dart';

Future<String> _resolveInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final storedLoggedIn = await AuthStorage.readIsLoggedIn(prefs);
  final session = Supabase.instance.client.auth.currentSession;

  if (storedLoggedIn && session != null) {
    return '/home';
  }

  if (storedLoggedIn && session == null) {
    await AuthStorage.setLoggedIn(prefs, value: false);
  }

  return '/login';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: false,
  );

  final initialRoute = await _resolveInitialRoute();

  runApp(
    ProviderScope(
      overrides: [
        initialRouteProvider.overrideWithValue(initialRoute),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = AppTheme.lightTheme;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
    );
  }
}
