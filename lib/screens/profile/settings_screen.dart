import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Account settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(title: const Text('Signed in as'), subtitle: Text(user?.email ?? '')),
          const ListTile(
            title: Text('Password storage'),
            subtitle: Text('Passwords are handled by Firebase Authentication and are never saved in the app.'),
          ),
          FilledButton(
            onPressed: user == null
                ? null
                : () async {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email);
                    if (context.mounted) showMessage(context, 'Password reset email sent');
                  },
            child: const Text('Send password reset email'),
          ),
          const SizedBox(height: 24),
          Text('BabyShopHub 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
          const Text('Academic baby-products store. Order alerts appear in the notification bell. A signed Android build can also receive Firebase Cloud Messaging pushes.'),
        ],
      ),
    );
  }
}
