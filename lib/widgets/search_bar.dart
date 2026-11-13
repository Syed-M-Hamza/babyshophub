import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BabySearchBar extends StatelessWidget {
  const BabySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.hint = 'Search baby products',
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hint;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.navy),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}
