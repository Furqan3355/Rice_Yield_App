import 'package:flutter/material.dart';
import '/core/theme/theme.dart';

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});

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
