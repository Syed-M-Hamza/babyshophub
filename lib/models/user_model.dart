import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/parsers.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String profileImage;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'there' : parts.first;
  }

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: (data['uid'] as String?) ?? doc.id,
      fullName: (data['fullName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      profileImage: (data['profileImage'] as String?) ?? '',
      role: (data['role'] as String?) ?? 'customer',
      isActive: readBool(data['isActive'], true),
      createdAt: readDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': 'customer',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
