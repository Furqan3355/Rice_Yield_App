import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/theme/theme.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => context.pop(),
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
