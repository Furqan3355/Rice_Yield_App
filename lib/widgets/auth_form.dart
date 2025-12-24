import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const AuthForm({
    super.key,
    required this.formKey,
    required this.children,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (child) => Padding(
                padding: padding,
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}