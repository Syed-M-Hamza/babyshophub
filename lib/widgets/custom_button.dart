import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label);
    if (outlined) {
      return OutlinedButton(onPressed: loading ? null : onPressed, child: child);
    }
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}
