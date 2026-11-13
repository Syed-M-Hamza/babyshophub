import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'weak-password':
      return 'Choose a stronger password of at least 6 characters.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email or password is incorrect.';
    case 'too-many-requests':
      return 'Too many attempts. Wait a moment and try again.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'user-disabled':
      return 'This account has been disabled.';
    default:
      return error.message ?? 'Authentication failed. Please try again.';
  }
}
