import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../utils/auth_messages.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown', message: 'Account could not be created.');
      }
      await user.updateDisplayName(fullName.trim());
      final profile = AppUser(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        profileImage: '',
        role: 'customer',
        isActive: true,
        createdAt: null,
      );
      await _firestore.collection('users').doc(user.uid).set(profile.toCreateMap());
    } on FirebaseAuthException {
      rethrow;
    } catch (error) {
      final uid = credential?.user?.uid;
      if (uid != null) {
        await _auth.currentUser?.delete();
      }
      throw FirebaseAuthException(code: 'profile-create-failed', message: error.toString());
    }
  }

  Future<void> login({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  String messageFor(FirebaseAuthException error) => authErrorMessage(error);
}
