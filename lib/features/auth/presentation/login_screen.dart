import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import '/core/theme/theme.dart';
import '/core/utils/validators.dart'; // Validators import
import '/core/routes/route_names.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/password_field.dart';
import '/core/widgets/custom_text_field.dart';
import 'package:rice_yield_app/core/widgets/app_logo.dart';
import 'dart:async';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _showServerError = true;
  Timer? _serverErrorTimer;

  @override
  void initState() {
    super.initState();
    // Clear any previous errors when entering login screen
    Future.microtask(() {
      if (mounted) ref.read(authNotifierProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _serverErrorTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go(RouteNames.getHomePath());
    }
  }

  void _clearError() {
    ref.read(authNotifierProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to show/hide server error UI
    ref.listen(authNotifierProvider, (prev, next) {
      final prevError = prev?.error;
      final nextError = next.error;
      if (prevError != nextError) {
        if (nextError != null) {
          setState(() => _showServerError = true);
          _serverErrorTimer?.cancel();
          _serverErrorTimer = Timer(const Duration(seconds: 8), () {
            if (mounted) setState(() => _showServerError = false);
          });
        } else {
          _serverErrorTimer?.cancel();
          if (mounted) setState(() => _showServerError = false);
        }
      }
    });
    
    final authState = ref.watch(authNotifierProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: AppLogo(width: 120, height: 120)),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back',
                  style: AppTheme.headlineLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to Rice Yield Predictor',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                // Form with autovalidateMode
                AuthForm(
                  formKey: _formKey,
                 // autovalidateMode: AutovalidateMode.onUserInteraction, //  Add this
                  children: [
                    // Email
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                      onChanged: (_) => _clearError(),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    PasswordField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: Validators.validatePassword,
                      onChanged: (_) => _clearError(),
                    ),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          context.push(RouteNames.getForgotPasswordPath());
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error Message (server/auth errors persist briefly)
                    if (authState.error != null && _showServerError)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                authState.error!,
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('Sign In', style: AppTheme.buttonText),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(RouteNames.getSignupPath());
                      },
                      child: Text(
                        'Sign Up',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}