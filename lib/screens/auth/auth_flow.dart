import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  String _page = 'login';

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      'register' => RegisterScreen(onLogin: () => setState(() => _page = 'login')),
      'forgot' => ForgotPasswordScreen(onLogin: () => setState(() => _page = 'login')),
      _ => LoginScreen(
        onForgot: () => setState(() => _page = 'forgot'),
      ),
    };
  }
}
