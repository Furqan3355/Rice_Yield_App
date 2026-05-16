import 'package:flutter/material.dart';

class AuthForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
   //  Add this

  const AuthForm({
    super.key,
    required this.formKey,
    required this.children,
    this.padding = const EdgeInsets.all(0),
    // Add this
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
       // ✅ Pass to Form widget
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