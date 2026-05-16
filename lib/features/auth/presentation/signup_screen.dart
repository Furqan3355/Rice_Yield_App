import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rice_yield_app/core/providers/app_providers.dart';
import '/core/theme/theme.dart';
import '/core/utils/validators.dart';
import '/core/widgets/custom_button.dart';
import '/core/widgets/custom_text_field.dart';
import '/core/routes/route_names.dart';
import 'package:rice_yield_app/features/auth/presentation/widgets/auth_form.dart';
import 'dart:async';

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
    // Clear any previous errors when entering signup screen
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
    // Clear any previous server error
    _clearServerError();
    
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      // Show validation error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
          backgroundColor: Colors.green,
        ),
      );
      context.go(RouteNames.getHomePath());
    }
  }

  void _clearServerError() {
    _serverErrorTimer?.cancel();
    ref.read(authNotifierProvider.notifier).clearError();
    setState(() {
      _showServerError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth errors and show them for a short period unless cleared by typing
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
        // Don't clear on tap, only on field change
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Create Account'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Get Started',
                  style: AppTheme.headlineMedium.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to continue',
                  style: AppTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Form
                AuthForm(
                  formKey: _formKey,
                  //autovalidateMode: AutovalidateMode.onUserInteraction,
                  children: [
                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: Validators.validateName,
                      onChanged: (_) {
                        _clearServerError();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                      onChanged: (_) {
                        _clearServerError();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Field (Optional)
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number (Optional)',
                      hintText: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: (value) {
                        // If empty, it's optional
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        
                        // If only spaces or non-digits, treat as empty
                        final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digitsOnly.isEmpty) {
                          return null;
                        }
                        
                        // Validate only if user entered actual digits
                        return Validators.validatePhone(value);
                      },
                      onChanged: (_) {
                        _clearServerError();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.validatePassword,
                      onChanged: (_) {
                        _clearServerError();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        value, 
                        _passwordController.text
                      ),
                      onChanged: (_) {
                        _clearServerError();
                      },
                    ),

                    // Server Error Message (only for server/auth errors)
                    if (authState.error != null && _showServerError) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
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
                  ],
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: authState.isLoading ? null : _handleSignup,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(RouteNames.getLoginPath());
                      },
                      child: Text(
                        'Sign In',
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