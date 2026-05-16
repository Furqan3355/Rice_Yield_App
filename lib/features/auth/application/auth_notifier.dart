import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rice_yield_app/features/auth/domain/auth_state.dart' as local_auth;
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/features/auth/application/auth_service.dart';

class AuthNotifier extends Notifier<local_auth.AuthState> {
    // Update user name
    Future<void> updateUserName(String newName) async {
      try {
        _updateState(state.copyWith(isLoading: true, error: null));
        final authService = AuthService();
        await authService.updateProfile(name: newName);
        final prefs = await _prefs;
        await prefs.setString('user_name', newName);
        _updateState(state.copyWith(userName: newName, isLoading: false));
      } catch (e) {
        _updateState(state.copyWith(isLoading: false, error: 'Failed to update name.'));
      }
    }
  //  Router ko signal bhejne ke liye stream
  final _streamController = StreamController<local_auth.AuthState>.broadcast();
  Stream<local_auth.AuthState> get stream => _streamController.stream;

  @override
  local_auth.AuthState build() {
    // App start hote hi check karo user logged in hai ya nahi
    WidgetsBinding.instance.addPostFrameCallback((_) => checkAuthStatus());
    return local_auth.AuthState.initial();
  }

  SupabaseClient get _supabase => ref.read(supabaseProvider);
  Future<SharedPreferences> get _prefs async => await ref.read(sharedPreferencesProvider.future);

  //  Helper method jo state update karega aur router ko refresh signal bhejega
  void _updateState(local_auth.AuthState newState) {
    state = newState;
    if (!_streamController.isClosed) {
      _streamController.add(newState);
    }
  }

  // 1. Check Auth Status
  Future<void> checkAuthStatus() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      final prefs = await _prefs;
      _updateState(state.copyWith(
        isAuthenticated: true,
        userEmail: session.user.email,
        userName: prefs.getString('user_name') ?? session.user.userMetadata?['name'],
        userId: session.user.id,
      ));
    } else {
      _updateState(state.copyWith(isAuthenticated: false));
    }
  }

  // 2. Login Method (Metadata based - No Table Required)
  Future<bool> login(String email, String password) async {
    try {
      _updateState(state.copyWith(isLoading: true, error: null));
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        final name = response.user!.userMetadata?['name'] ?? 'User';
        final prefs = await _prefs;
        await prefs.setString('user_name', name);
        
        _updateState(state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: response.user!.email,
          userName: name,
          userId: response.user!.id,
        ));
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _updateState(state.copyWith(isLoading: false, error: e.message));
      return false;
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: 'Login failed. Check connection.'));
      return false;
    }
  }

  // 3. SignUp Method
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _updateState(state.copyWith(isLoading: true, error: null));
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name.trim(),
          if (phone != null) 'phone': phone.trim(),
        },
      );
      if (response.user != null) {
        _updateState(state.copyWith(isLoading: false, error: 'Check your email for confirmation!'));
        return true;
      }
      return false;
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  // 4. Reset Password Method
  Future<bool> resetPassword(String email) async {
    try {
      _updateState(state.copyWith(isLoading: true, error: null));
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.example.rice_yield_app://reset-password',
      );
      _updateState(state.copyWith(isLoading: false));
      return true;
    } catch (e) {
      _updateState(state.copyWith(isLoading: false, error: 'Failed to send reset email.'));
      return false;
    }
  }

  // 5. Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    final prefs = await _prefs;
    await prefs.clear();
    _updateState(local_auth.AuthState.initial());
  }

  void clearError() => _updateState(state.copyWith(clearError: true));
}
