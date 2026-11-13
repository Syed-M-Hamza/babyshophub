import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'clay_card.dart';

enum ClayBuddy { skincare, toys, clothes, feeding }

class ClayCartoonButton extends StatelessWidget {
  const ClayCartoonButton({super.key, required this.buddy, required this.label, required this.onTap});

  final ClayBuddy buddy;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (buddy) {
      ClayBuddy.skincare => const Color(0xFFF8D2D2),
      ClayBuddy.toys => const Color(0xFFF6D7B0),
      ClayBuddy.clothes => const Color(0xFFD7F0E4),
      ClayBuddy.feeding => const Color(0xFFD6E6FB),
    };
    return Clay(
      color: color,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      radius: 26,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 92, width: 92, child: CustomPaint(painter: _BuddyPainter(buddy))),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy, fontSize: 13)),
        ],
      ),
    );
  }
}

class _BuddyPainter extends CustomPainter {
  _BuddyPainter(this.buddy);

  final ClayBuddy buddy;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.9), width: size.width * 0.62, height: 12),
      Paint()..color = const Color(0x22000000),
    );
    final center = Offset(size.width / 2, size.height / 2 + 2);
    switch (buddy) {
      case ClayBuddy.skincare:
        _head(canvas, center, const Color(0xFFFFD8C2));
        _blush(canvas, center);
        _eyes(canvas, center, happy: true);
        _smile(canvas, center);
        _jar(canvas, Offset(size.width * 0.72, size.height * 0.72));
      case ClayBuddy.toys:
        _ears(canvas, center, const Color(0xFFE0A36A));
        _head(canvas, center, const Color(0xFFE8B57A), radius: 24);
        _snout(canvas, center);
        _eyes(canvas, center, happy: false);
      case ClayBuddy.clothes:
        _body(canvas, center, const Color(0xFFB7E4CF));
        _head(canvas, center.translate(0, -16), const Color(0xFFFFD8C2), radius: 18);
        _blush(canvas, center.translate(0, -16));
        _eyes(canvas, center.translate(0, -16), happy: true);
        _bow(canvas, center.translate(14, -28));
      case ClayBuddy.feeding:
        _head(canvas, center.translate(-6, -2), const Color(0xFFFFD8C2));
        _blush(canvas, center.translate(-6, -2));
        _eyes(canvas, center.translate(-6, -2), happy: true);
        _smile(canvas, center.translate(-6, -2));
        _bottle(canvas, Offset(size.width * 0.72, size.height * 0.62));
    }
  }

  void _head(Canvas canvas, Offset center, Color color, {double radius = 26}) {
    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(center.translate(-radius * 0.35, -radius * 0.35), radius * 0.28, Paint()..color = Colors.white.withValues(alpha: 0.55));
  }

  void _body(Canvas canvas, Offset center, Color color) {
    final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, 16), width: 36, height: 34), const Radius.circular(16));
    canvas.drawRRect(rect, Paint()..color = color);
  }

  void _ears(Canvas canvas, Offset center, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center.translate(-20, -22), 12, paint);
    canvas.drawCircle(center.translate(20, -22), 12, paint);
    final inner = Paint()..color = const Color(0xFFF3C9A0);
    canvas.drawCircle(center.translate(-20, -22), 6, inner);
    canvas.drawCircle(center.translate(20, -22), 6, inner);
  }

  void _snout(Canvas canvas, Offset center) {
    canvas.drawOval(Rect.fromCenter(center: center.translate(0, 8), width: 18, height: 14), Paint()..color = const Color(0xFFFFF1E4));
    canvas.drawCircle(center.translate(0, 6), 3, Paint()..color = const Color(0xFF8A5A3A));
  }

  void _eyes(Canvas canvas, Offset center, {required bool happy}) {
    final paint = Paint()
      ..color = const Color(0xFF3D3A55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (happy) {
      canvas.drawArc(Rect.fromCenter(center: center.translate(-8, -2), width: 8, height: 8), 0.2, 2.4, false, paint);
      canvas.drawArc(Rect.fromCenter(center: center.translate(8, -2), width: 8, height: 8), 0.5, 2.4, false, paint);
    } else {
      canvas.drawCircle(center.translate(-7, -2), 2.2, Paint()..color = const Color(0xFF3D3A55));
      canvas.drawCircle(center.translate(7, -2), 2.2, Paint()..color = const Color(0xFF3D3A55));
    }
  }

  void _blush(Canvas canvas, Offset center) {
    final paint = Paint()..color = const Color(0xFFFFB4B4).withValues(alpha: 0.8);
    canvas.drawOval(Rect.fromCenter(center: center.translate(-12, 8), width: 8, height: 5), paint);
    canvas.drawOval(Rect.fromCenter(center: center.translate(12, 8), width: 8, height: 5), paint);
  }

  void _smile(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFFE08A5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCenter(center: center.translate(0, 6), width: 12, height: 8), 0.2, 2.6, false, paint);
  }

  void _jar(Canvas canvas, Offset center) {
    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 16, height: 18), const Radius.circular(5));
    canvas.drawRRect(body, Paint()..color = const Color(0xFFFFF8F2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, -10), width: 18, height: 6), const Radius.circular(3)),
      Paint()..color = const Color(0xFFF4B183),
    );
  }

  void _bow(Canvas canvas, Offset center) {
    final paint = Paint()..color = const Color(0xFFF4B183);
    canvas.drawCircle(center.translate(-6, 0), 5, paint);
    canvas.drawCircle(center.translate(6, 0), 5, paint);
    canvas.drawCircle(center, 2.5, Paint()..color = const Color(0xFFE08A5A));
  }

  void _bottle(Canvas canvas, Offset center) {
    final paint = Paint()..color = const Color(0xFF8FB7EE);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 12, height: 22), const Radius.circular(6)), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, -13), width: 8, height: 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF5E86C4),
    );
    canvas.drawCircle(center.translate(0, 2), 2, Paint()..color = Colors.white.withValues(alpha: 0.8));
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter oldDelegate) => oldDelegate.buddy != buddy;
}
