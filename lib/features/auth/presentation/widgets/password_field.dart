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
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
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

  /// Obscure only when there is input — keeps hint visible when empty (like email).
  bool get _shouldObscure =>
      widget.obscureText && widget.controller.text.isNotEmpty;

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
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
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final borderRadius = BorderRadius.circular(12);

    InputBorder borderOr(OutlineInputBorder? fromTheme, Color fallback) {
      return fromTheme ??
          OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: fallback),
          );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _shouldObscure,
      validator: widget.validator,
      onChanged: _handleChanged,
      focusNode: _focusNode,
      autovalidateMode: widget.hideErrorOnEditing
          ? (_showError ? AutovalidateMode.always : AutovalidateMode.disabled)
          : AutovalidateMode.disabled,
      decoration: InputDecoration(
        labelText:
            (widget.labelText == null || widget.labelText!.isEmpty)
                ? null
                : widget.labelText,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
          onPressed: widget.onToggleVisibility,
        ),
        border: borderOr(
          inputTheme.border as OutlineInputBorder?,
          Colors.grey.shade300,
        ),
        enabledBorder: borderOr(
          inputTheme.enabledBorder as OutlineInputBorder?,
          Colors.grey.shade300,
        ),
        focusedBorder: borderOr(
          inputTheme.focusedBorder as OutlineInputBorder?,
          Theme.of(context).colorScheme.primary,
        ),
        errorBorder: borderOr(
          inputTheme.errorBorder as OutlineInputBorder?,
          Colors.red,
        ),
        focusedErrorBorder: borderOr(
          inputTheme.focusedErrorBorder as OutlineInputBorder?,
          Colors.red,
        ),
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ?? Colors.white,
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: inputTheme.hintStyle ??
            TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIconColor: inputTheme.prefixIconColor,
      ),
    );
  }
}
