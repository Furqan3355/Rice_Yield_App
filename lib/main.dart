import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import '/providers/app_providers.dart';
import '/utils/theme.dart';
import 'package:flutter/services.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, //fullscreen properly
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    //authCallbackUrlHostname: 'login-callback',
    debug: false,
  );

  runApp(
    ProviderScope(
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