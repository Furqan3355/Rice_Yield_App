import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import '/models/auth_state.dart' as local_auth;
import '../models/report_model.dart';
import 'auth_notifier.dart';

// ============ CORE DEPENDENCIES ============
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// ============ STATE NOTIFIERS ============
final authNotifierProvider = NotifierProvider<AuthNotifier, local_auth.AuthState>(AuthNotifier.new);

// ============ REPORTS PROVIDER ============
final reportsProvider = StreamProvider<List<Report>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final authState = ref.watch(authNotifierProvider);
  final userId = authState.userId;

  if (userId == null) return Stream.value([]);

  return supabase
      .from('reports')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => Report.fromJson(json)).toList());
});

// ============ ROUTER ============
final routerProvider = Provider<GoRouter>((ref) => AppRouter(ref: ref).router);

// ============ UTILITY PROVIDERS (Fixing Undefined Errors) ============
class LoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setLoading(bool value) => state = value;
}

// ✅ loadingProvider define kar diya
final loadingProvider = NotifierProvider<LoadingNotifier, bool>(LoadingNotifier.new);

class ErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setError(String? value) => state = value;
}

// ✅ errorProvider define kar diya
final errorProvider = NotifierProvider<ErrorNotifier, String?>(ErrorNotifier.new);