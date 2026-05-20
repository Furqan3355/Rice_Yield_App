import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import 'package:rice_yield_app/core/utils/app_colors.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/password_field.dart';
import '/core/routes/route_names.dart';
import '/core/theme/theme.dart';
import '/core/utils/validators.dart';
import '/core/widgets/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    _clearServerError();
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go(RouteNames.getHomePath());
    }
  }

  void _clearServerError() {
    _serverErrorTimer?.cancel();
    ref.read(authNotifierProvider.notifier).clearError();
    setState(() => _showServerError = false);
  }

  InputDecorationTheme _fieldTheme(BuildContext context) {
    return InputDecorationTheme(
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
    );
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 24, 0),
                child: const AuthBackButton(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: _fieldTheme(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create Account',
                          style: AppTheme.headlineLarge.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Register to start using Rice Yield Predictor',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColors.subtitle,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const AuthFieldLabel('Full name'),
                        const SizedBox(height: 6),
                        AuthForm(
                          formKey: _formKey,
                          children: [
                            CustomTextField(
                              controller: _nameController,
                              labelText: '',
                              hintText: 'Enter your full name',
                              prefixIcon: const Icon(Iconsax.user, size: 20),
                              validator: Validators.validateName,
                              hideErrorOnEditing: false,
                              onChanged: (_) => _clearServerError(),
                            ),
                            const SizedBox(height: 14),
                            const AuthFieldLabel('Email address'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _emailController,
                              labelText: '',
                              hintText: 'example@email.com',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Iconsax.sms, size: 20),
                              validator: Validators.validateEmail,
                              hideErrorOnEditing: false,
                              onChanged: (_) => _clearServerError(),
                            ),
                            const SizedBox(height: 14),
                            const AuthFieldLabel('Phone number (optional)'),
                            const SizedBox(height: 6),
                            CustomTextField(
                              controller: _phoneController,
                              labelText: '',
                              hintText: 'Enter your phone number',
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Iconsax.call, size: 20),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final digitsOnly =
                                    value.replaceAll(RegExp(r'[^0-9]'), '');
                                if (digitsOnly.isEmpty) return null;
                                return Validators.validatePhone(value);
                              },
                              hideErrorOnEditing: false,
                              onChanged: (_) => _clearServerError(),
                            ),
                            const SizedBox(height: 14),
                            const AuthFieldLabel('Password'),
                            const SizedBox(height: 6),
                            PasswordField(
                              controller: _passwordController,
                              labelText: '',
                              hintText: '********',
                              obscureText: _obscurePassword,
                              onToggleVisibility: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                              validator: Validators.validatePassword,
                              hideErrorOnEditing: false,
                              onChanged: (_) => _clearServerError(),
                            ),
                            const SizedBox(height: 14),
                            const AuthFieldLabel('Confirm password'),
                            const SizedBox(height: 6),
                            PasswordField(
                              controller: _confirmPasswordController,
                              labelText: '',
                              hintText: '********',
                              obscureText: _obscureConfirmPassword,
                              onToggleVisibility: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                              validator: (value) =>
                                  Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                              hideErrorOnEditing: false,
                              onChanged: (_) => _clearServerError(),
                            ),
                            if (authState.error != null && _showServerError)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(top: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.errorColor
                                        .withValues(alpha: 0.3),
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
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed:
                                authState.isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppTheme.primaryColor
                                  .withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: authState.isLoading
                                ? const SizedBox.shrink()
                                : const Icon(Iconsax.user_add, size: 22),
                            label: authState.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: AppTheme.buttonText,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppColors.subtitle,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.push(RouteNames.getLoginPath());
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign In',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
