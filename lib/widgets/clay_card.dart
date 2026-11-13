import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class Clay extends StatelessWidget {
  const Clay({
    super.key,
    required this.child,
    this.color = const Color(0xFFF7F1EA),
    this.padding = const EdgeInsets.all(14),
    this.radius = 28,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.4),
      boxShadow: [
        BoxShadow(color: Colors.white.withValues(alpha: 0.95), offset: const Offset(-8, -8), blurRadius: 16),
        BoxShadow(color: color.withValues(alpha: 0.55), offset: const Offset(10, 12), blurRadius: 18),
        const BoxShadow(color: Color(0x14000000), offset: Offset(4, 6), blurRadius: 10),
      ],
    );
    final body = Container(padding: padding, decoration: shape, child: child);
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: body),
    );
  }
}

class ClayIconButton extends StatelessWidget {
  const ClayIconButton({super.key, required this.icon, required this.onPressed, this.color = const Color(0xFFFFF7F2)});

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
              BoxShadow(color: Color(0x22000000), offset: Offset(3, 4), blurRadius: 6),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.navy),
        ),
      ),
    );
  }
}
