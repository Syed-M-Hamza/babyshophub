import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/profile_photo_memory.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = FirestoreService();
  final _storage = StorageService();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: user.fullName);
    _phone = TextEditingController(text: user.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: LoadingWidget());
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                BabyTextField(controller: _name, label: 'Full name', validator: Validators.fullName),
                const SizedBox(height: 12),
                ListTile(contentPadding: EdgeInsets.zero, title: const Text('Email'), subtitle: Text(user.email)),
                const SizedBox(height: 12),
                BabyTextField(controller: _phone, label: 'Phone number', keyboardType: TextInputType.phone, validator: Validators.phone),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Email is managed by Firebase Authentication and cannot be edited here.'),
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFFFCE5E5),
              backgroundImage: _bytes == null ? null : MemoryImage(_bytes!),
              child: _bytes == null ? const Icon(Icons.person, size: 36) : null,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
              if (file == null) return;
              final bytes = await file.readAsBytes();
              setState(() => _bytes = bytes);
              ProfilePhotoMemory.instance.set(bytes);
            },
            icon: const Icon(Icons.photo_outlined),
            label: Text(_bytes == null ? 'Choose profile photo' : 'Photo selected'),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Save profile',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_bytes != null) ProfilePhotoMemory.instance.set(_bytes!);
              context.read<AuthProvider>().applyLocalProfile(fullName: _name.text.trim(), phone: _phone.text.trim(), profileImage: user.profileImage.isEmpty ? 'local-photo' : user.profileImage);
              showMessage(context, 'Profile updated');
              Navigator.pop(context);
              final bytes = _bytes;
              final uid = user.uid;
              final name = _name.text.trim();
              final phone = _phone.text.trim();
              Future<void>(() async {
                try {
                  String? image;
                  if (bytes != null) {
                    image = await _storage.uploadBytes(path: 'users/$uid/profile.jpg', bytes: bytes, contentType: 'image/jpeg').timeout(const Duration(seconds: 3));
                  }
                  await _store.updateProfile(uid: uid, fullName: name, phone: phone, profileImage: image).timeout(const Duration(seconds: 3));
                } catch (_) {}
              });
            },
          ),
        ],
      ),
    );
  }
}
