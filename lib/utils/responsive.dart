import 'package:flutter/material.dart';

bool isWideScreen(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;

int productColumns(double width) {
  return 2;
}

class ShopFrame extends StatelessWidget {
  const ShopFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1120), child: child),
    );
  }
}
