import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/providers/app_providers.dart';
import '/utils/theme.dart';
import '/widgets/custom_button.dart';
import '/widgets/custom_text_field.dart';
import '/routes/route_names.dart';
import '/widgets/auth_form.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _isEmailSent = true;
      });
    }
  }

  void _clearError() {
    ref.read(authNotifierProvider.notifier).clearError();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _clearError();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Reset Password'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha:255*0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                if (!_isEmailSent) ...[
                  // Instructions
                  Text(
                    'Reset Password',
                    style: AppTheme.headlineMedium.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address and we will send you a link to reset your password.',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Form
                  AuthForm(
                    formKey: _formKey,
                    children: [
                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'Enter your registered email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onChanged: (_) => _clearError(),
                      ),

                      // Error Message
                      if (authState.error != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha:255*0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorColor.withValues(alpha:255*0.3),
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

                  // Reset Button
                  CustomButton(
                    text: 'Send Reset Link',
                    onPressed: authState.isLoading ? null : () => _handleResetPassword(),
                    isLoading: authState.isLoading,
                  ),
                ] else ...[
                  // Success Message
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withValues(alpha:255*0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            size: 40,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Email Sent!',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We have sent a password reset link to your email address.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _emailController.text,
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Back to Login',
                          onPressed: () {
                            context.go(RouteNames.getLoginPath());
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            _handleResetPassword();
                          },
                          child: Text(
                            'Resend Email',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Back to Login
                if (!_isEmailSent)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go(RouteNames.getLoginPath());
                      },
                      child: Text(
                        'Back to Login',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}