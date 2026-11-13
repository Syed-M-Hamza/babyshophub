import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onForgot});

  final VoidCallback onForgot;

  @override
  State<LoginScreen> createState() => _ShopLoginState();
}

class _ShopLoginState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _hint;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _hint = 'Enter your email and password to continue.');
      return;
    }
    setState(() {
      _loading = true;
      _hint = null;
    });
    await context.read<AuthProvider>().login(email: email, password: password);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppColors.navy)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(color: Color(0xFFF8D2D2), shape: BoxShape.circle),
                child: const Icon(Icons.child_care, size: 42, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Welcome back', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 6),
            const Text('Sign in to save favourites and checkout.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7C746E))),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 12))],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _field('Email', Icons.mail_outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    onSubmitted: (_) => _submit(),
                    decoration: _field('Password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: widget.onForgot, child: const Text('Forgot password?')),
                  ),
                  if (_hint != null) Text(_hint!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8A5A3A))),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF4B183),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: Text(_loading ? 'Signing in…' : 'Login', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _field(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFE08A5A)),
      filled: true,
      fillColor: const Color(0xFFFFF8F4),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}
