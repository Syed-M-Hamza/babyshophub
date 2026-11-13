import 'package:flutter/material.dart';

class BabyTextField extends StatelessWidget {
  const BabyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(labelText: label, suffixIcon: suffix),
    );
  }
}
