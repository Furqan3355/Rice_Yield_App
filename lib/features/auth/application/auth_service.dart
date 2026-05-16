import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
class AuthService {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  // 1. Login Method
   Future<AuthResponse> login(String email, String password) async {
    try {
      debugPrint('🟡 Login attempt: $email');
      
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

     // debugPrint('🟢 Login successful: ${response.user?.email}');
      return response;
    } catch (e) {
      //debugPrint('🔴 Login error: $e');
      rethrow;
    }
  }

  // 2. Signup Method (Simplified)
  Future<AuthResponse> signup({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      debugPrint('🟡 Signup attempt: $email');

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
        emailRedirectTo: 'your-app://login-callback',
      );

      debugPrint('🟢 Signup successful: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('🔴 Signup error: $e');
      rethrow;
    }
  }

  // 3. Get Current User Profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = supabaseClient.auth.currentUser;
      
      if (user != null) {
        // Supabase auth se user metadata directly access karo
        final metadata = user.userMetadata;
        
        // Agar aapko custom fields chahiye toh 'profiles' table use karo
        try {
          final profile = await supabaseClient
              .from('profiles')  // Ya 'users' table
              .select()
              .eq('id', user.id)
              .single();
          
          return profile;
        } catch (e) {
          debugPrint('🟡 Profile not found, using auth metadata');
          return {
            'id': user.id,
            'email': user.email,
            'name': metadata?['name'],
            'phone': metadata?['phone'],
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('🔴 Get profile error: $e');
      return null;
    }
  }

  // 4. Current User Check
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  // 5. Logout
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  // 6. Password Reset
  Future<void> resetPassword(String email) async {
    await supabaseClient.auth.resetPasswordForEmail(
      email,
      redirectTo: 'your-app://reset-password',
    );
  }

  // 7. Update User Profile
  Future<void> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Update auth metadata
      await supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            'phone': phone,
          },
        ),
      );

      // Agar profiles table hai toh wahan bhi update karo
      await supabaseClient
          .from('profiles')
          .update({
            'full_name': name,
            'phone': phone,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      debugPrint('🔴 Update profile error: $e');
      rethrow;
    }
  }
}