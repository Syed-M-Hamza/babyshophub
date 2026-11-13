import 'package:flutter/material.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

void popToRoot() {
  final navigator = rootNavigatorKey.currentState;
  if (navigator != null && navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
