import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await context.read<AuthProvider>().register(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  BabyTextField(controller: _name, label: 'Full name', validator: Validators.fullName, textInputAction: TextInputAction.next),
                  const SizedBox(height: 12),
                  BabyTextField(controller: _email, label: 'Email address', keyboardType: TextInputType.emailAddress, validator: Validators.email, textInputAction: TextInputAction.next),
                  const SizedBox(height: 12),
                  BabyTextField(
                    controller: _phone,
                    label: 'Phone number',
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  BabyTextField(
                    controller: _password,
                    label: 'Password',
                    obscure: _obscure,
                    validator: Validators.password,
                    suffix: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                  ),
                  const SizedBox(height: 12),
                  BabyTextField(controller: _confirm, label: 'Confirm password', obscure: _obscure, validator: (value) => Validators.confirmPassword(value, _password.text)),
                ],
              ),
            ),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
            const SizedBox(height: 16),
            CustomButton(label: 'Register', loading: _loading, onPressed: _submit),
            TextButton(onPressed: widget.onLogin, child: const Text('Already have an account? Login')),
          ],
        ),
      ),
    );
  }
}
