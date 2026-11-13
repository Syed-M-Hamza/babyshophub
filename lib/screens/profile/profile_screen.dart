import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/profile_photo_memory.dart';
import '../../theme/app_colors.dart';
import '../orders/orders_screen.dart';
import '../seller/seller_screen.dart';
import '../support/support_screen.dart';
import 'addresses_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import '../admin/admin_shell.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../home/customer_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final name = user?.fullName ?? 'Guest';
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              ListenableBuilder(
                listenable: ProfilePhotoMemory.instance,
                builder: (context, _) {
                  final bytes = ProfilePhotoMemory.instance.bytes;
                  final hasPhoto = bytes != null || (user != null && user.profileImage.isNotEmpty);
                  return InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () async {
                      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
                      if (file == null) return;
                      ProfilePhotoMemory.instance.set(await file.readAsBytes());
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.babyPink,
                      backgroundImage: bytes != null
                          ? MemoryImage(bytes)
                          : user != null && user.profileImage.isNotEmpty
                          ? CachedNetworkImageProvider(user.profileImage)
                          : null,
                      child: hasPhoto ? null : Text(name.isEmpty ? 'G' : name[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text(user?.email ?? 'Browsing the boutique'),
                    if (user != null && user.phone.isNotEmpty) Text(user.phone),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (user == null || user.email.isEmpty)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF4B183),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (loginContext) => LoginScreen(
                      onForgot: () {
                        Navigator.of(loginContext).push(
                          MaterialPageRoute(builder: (_) => ForgotPasswordScreen(onLogin: () => Navigator.of(loginContext).pop())),
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          if (user == null || user.email.isEmpty) const SizedBox(height: 12),
          _ProfileTile(icon: Icons.location_on_outlined, title: 'Manage addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()))),
          if (user != null && user.email.isNotEmpty) ...[
            _ProfileTile(icon: Icons.edit_outlined, title: 'Edit profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _ProfileTile(icon: Icons.settings_outlined, title: 'Account settings', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          ],
          _ProfileTile(icon: Icons.receipt_long_outlined, title: 'My orders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
          _ProfileTile(
            icon: Icons.favorite_outline,
            title: 'My wishlist',
            onTap: () => ShellTab.maybeOf(context)?.select(2),
          ),
          _ProfileTile(icon: Icons.support_agent_outlined, title: 'Support', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()))),
          _ProfileTile(icon: Icons.storefront_outlined, title: 'Our store', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerScreen()))),
          if (user != null)
            _ProfileTile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => context.read<AuthProvider>().logout(),
            ),
          if (auth.isAdmin)
            _ProfileTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin dashboard',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell())),
            ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap),
    );
  }
}
