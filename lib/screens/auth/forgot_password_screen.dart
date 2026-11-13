import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await context.read<AuthProvider>().sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = null;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Enter your account email. Firebase will send a password reset link. Your password is never stored in the app.'),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: BabyTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: Validators.email),
          ),
          if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
          if (_sent) const Padding(padding: EdgeInsets.only(top: 12), child: Text('Your reset request is saved. You can return to login.')),
          const SizedBox(height: 16),
          CustomButton(label: 'Send reset link', loading: _loading, onPressed: _submit),
          TextButton(onPressed: widget.onLogin, child: const Text('Back to login')),
        ],
      ),
    );
  }
}

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        title: 'Account inactive',
        message: 'An administrator has paused this account. You can log out and contact support from another account.',
        icon: Icons.lock_outline,
        action: CustomButton(label: 'Logout', onPressed: () => context.read<AuthProvider>().logout()),
      ),
    );
  }
}
