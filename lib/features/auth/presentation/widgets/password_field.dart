import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final FocusNode? focusNode;
  /// If true, hide validation error while editing and show it on blur.
  final bool hideErrorOnEditing;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.hintText = 'Enter your password',
    this.validator,
    this.onChanged,
    required this.obscureText,
    required this.onToggleVisibility,
    this.focusNode,
    this.hideErrorOnEditing = true,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  late FocusNode _focusNode;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      if (_showError) setState(() => _showError = false);
    } else {
      if (widget.hideErrorOnEditing) {
        setState(() => _showError = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final form = context.findAncestorStateOfType<FormState>();
          if (form != null) form.validate();
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    if (_showError) setState(() => _showError = false);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      validator: widget.validator,
      onChanged: _handleChanged,
      focusNode: _focusNode,
      autovalidateMode: widget.hideErrorOnEditing
          ? (_showError ? AutovalidateMode.always : AutovalidateMode.disabled)
          : AutovalidateMode.disabled,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: widget.onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}