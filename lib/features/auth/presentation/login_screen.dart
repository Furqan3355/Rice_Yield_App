import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/constants/app_assets.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/auth/domain/auth_state.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/password_field.dart';
import '/core/routes/route_names.dart';
import '/core/theme/theme.dart';
import '/core/utils/validators.dart';
import '/core/widgets/custom_text_field.dart';

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
    FocusScope.of(context).unfocus();
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = screenHeight * 0.48;
    final contentOverlap = screenHeight * 0.38;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AvifImage.asset(
                    AppAssets.riceFieldImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: imageHeight,
                  ),
                  Container(
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: contentOverlap),
                  _LoginContentCard(
                    authState: authState,
                    showServerError: _showServerError,
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    onTogglePassword: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    onClearError: _clearError,
                    onLogin: _handleLogin,
                    onForgotPassword: () {
                      context.push(RouteNames.getForgotPasswordPath());
                    },
                    onRegister: () {
                      context.push(RouteNames.getSignupPath());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginContentCard extends StatelessWidget {
  const _LoginContentCard({
    required this.authState,
    required this.showServerError,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onClearError,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onRegister,
  });

  final AuthState authState;
  final bool showServerError;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onClearError;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIconColor: AppTheme.primaryColor,
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 18,
            spreadRadius: 2,
            offset: const Offset(0, -10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.65),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Theme(
              data: fieldTheme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: AppTheme.headlineLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue to Rice Yield Predictor',
                    style: AppTheme.bodyMedium.copyWith(color: AppColors.subtitle),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel('Email address'),
                  const SizedBox(height: 6),
                  AuthForm(
                    formKey: formKey,
                    children: [
                      CustomTextField(
                        controller: emailController,
                        labelText: '',
                        hintText: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Iconsax.sms, size: 20),
                        validator: Validators.validateEmail,
                        hideErrorOnEditing: false,
                        onChanged: (_) => onClearError(),
                      ),
                      const SizedBox(height: 14),
                      _FieldLabel('Password'),
                      const SizedBox(height: 6),
                      PasswordField(
                        controller: passwordController,
                        labelText: '',
                        hintText: '********',
                        obscureText: obscurePassword,
                        onToggleVisibility: onTogglePassword,
                        validator: Validators.validatePassword,
                        hideErrorOnEditing: false,
                        onChanged: (_) => onClearError(),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          child: Text(
                            'Forgot password?',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (authState.error != null && showServerError)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.errorColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: authState.isLoading ? null : onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: authState.isLoading
                          ? const SizedBox.shrink()
                          : const Icon(Iconsax.user, size: 22),
                      label: authState.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Login', style: AppTheme.buttonText),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTheme.bodyMedium.copyWith(color: AppColors.subtitle),
                      ),
                      TextButton(
                        onPressed: onRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Register',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
        color: AppTheme.primaryColor,
      ),
    );
  }
}
