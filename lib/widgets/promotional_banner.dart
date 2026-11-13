import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({super.key, required this.onShop});

  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pastelPeach,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Soft savings', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.navy)),
                const SizedBox(height: 6),
                Text(
                  'Up to 20% off everyday baby essentials',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 8),
                const Text('Clothing, care, feeding and play — packed with care.'),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onShop,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.navy,
                    minimumSize: const Size(120, 44),
                  ),
                  child: const Text('Shop now'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.babyPink, shape: BoxShape.circle),
            child: const Icon(Icons.child_care, size: 42, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}
