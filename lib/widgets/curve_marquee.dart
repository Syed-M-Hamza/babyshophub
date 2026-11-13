import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CurveMarquee extends StatefulWidget {
  const CurveMarquee({super.key});

  @override
  State<CurveMarquee> createState() => _CurveMarqueeState();
}

class _CurveMarqueeState extends State<CurveMarquee> with SingleTickerProviderStateMixin {
  static const _message = 'Soft cotton   ·   Gentle skincare   ·   Toys for little hands   ·   Cute clothes   ·   Easy feeding   ·   ';
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ClipPath(
            clipper: const _WaveClipper(),
            child: ColoredBox(
              color: const Color(0xFFF8D7D2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const line = '$_message$_message';
                  final shift = constraints.maxWidth - (_controller.value * (constraints.maxWidth + 520));
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        left: shift,
                        child: Text(
                          line,
                          maxLines: 1,
                          style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.2),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 10)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, 10)
      ..quadraticBezierTo(size.width * 0.75, 20, size.width, 8)
      ..lineTo(size.width, size.height - 8)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width * 0.5, size.height - 12)
      ..quadraticBezierTo(size.width * 0.25, size.height - 24, 0, size.height - 8)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
