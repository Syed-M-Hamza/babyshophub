import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(color: AppColors.pastelPeach, shape: BoxShape.circle),
                child: const Icon(Icons.child_care, size: 64, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 24),
            Text('BabyShopHub', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Soft things for little ones', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 28),
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.softOrange)),
          ],
        ),
      ),
    );
  }
}
