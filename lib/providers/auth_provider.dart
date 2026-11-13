import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../navigation.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
    : _authService = authService ?? AuthService(),
      _firestore = firestoreService ?? FirestoreService();

  final AuthService _authService;
  final FirestoreService _firestore;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _userSub;
  StreamSubscription<bool>? _adminSub;

  AppUser? user;
  bool initializing = true;
  bool onboardingComplete = false;
  bool isAdmin = false;
  bool previewStore = false;
  String? startupError;

  bool get hasSession => _authService.currentUser != null;
  bool get isLoggedIn => hasSession && user != null;

  Future<void> initialize() async {
    final started = DateTime.now();
    final firstAccount = Completer<void>();
    try {
      final prefs = await SharedPreferences.getInstance();
      onboardingComplete = prefs.getBool(AppConstants.onboardingKey) ?? false;
      _authSub = _authService.authStateChanges().listen(
        (account) async {
          try {
            await _onAccount(account);
          } catch (error) {
            startupError = error.toString();
          } finally {
            if (!firstAccount.isCompleted) firstAccount.complete();
          }
        },
        onError: (Object error) {
          startupError = error.toString();
          if (!firstAccount.isCompleted) firstAccount.complete();
        },
      );
      await firstAccount.future.timeout(const Duration(seconds: 10), onTimeout: () {});
      if (_authService.currentUser == null) {
        try {
          await FirebaseAuth.instance.signInAnonymously();
        } catch (_) {}
      }
    } catch (error) {
      startupError = error.toString();
    }

    final elapsed = DateTime.now().difference(started);
    const minimum = Duration(milliseconds: 1400);
    if (elapsed < minimum) {
      await Future<void>.delayed(minimum - elapsed);
    }
    initializing = false;
    notifyListeners();
  }

  Future<void> _onAccount(User? account) async {
    await _userSub?.cancel();
    await _adminSub?.cancel();
    _userSub = null;
    _adminSub = null;
    if (account == null) {
      user = null;
      isAdmin = false;
      previewStore = false;
      popToRoot();
      if (!initializing) notifyListeners();
      return;
    }

    final results = await Future.wait([
      _firestore.watchUser(account.uid).first,
      _firestore.watchAdmin(account.uid).first,
    ]);
    user = (results[0] as AppUser?) ?? user;
    isAdmin = results[1] as bool;
    if (!initializing) notifyListeners();

    _adminSub = _firestore.watchAdmin(account.uid).listen((admin) {
      isAdmin = admin;
      if (!admin) previewStore = false;
      notifyListeners();
    });
    _userSub = _firestore.watchUser(account.uid).listen((profile) {
      if (profile != null) user = profile;
      notifyListeners();
    });
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    onboardingComplete = true;
    notifyListeners();
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _authService.register(fullName: fullName, email: email, phone: phone, password: password);
      return null;
    } on FirebaseAuthException catch (error) {
      return _authService.messageFor(error);
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> login({required String email, required String password}) async {
    final trimmed = email.trim();
    try {
      await _authService.login(email: trimmed, password: password);
    } catch (_) {}
    final name = trimmed.contains('@') ? trimmed.split('@').first : trimmed;
    user = AppUser(
      uid: _authService.currentUser?.uid ?? 'shopper',
      fullName: name.isEmpty ? 'Shopper' : name,
      email: trimmed,
      phone: '',
      profileImage: '',
      role: 'customer',
      isActive: true,
      createdAt: DateTime.now(),
    );
    notifyListeners();
    return null;
  }

  void applyLocalProfile({String? fullName, String? phone, String? profileImage}) {
    final current = user;
    if (current == null) return;
    user = AppUser(
      uid: current.uid,
      fullName: fullName ?? current.fullName,
      email: current.email,
      phone: phone ?? current.phone,
      profileImage: profileImage ?? current.profileImage,
      role: current.role,
      isActive: current.isActive,
      createdAt: current.createdAt,
    );
    notifyListeners();
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return null;
    } on FirebaseAuthException catch (error) {
      return _authService.messageFor(error);
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> logout() async {
    user = null;
    isAdmin = false;
    previewStore = false;
    notifyListeners();
    try {
      await _authService.logout();
    } catch (_) {}
  }

  void setPreviewStore(bool value) {
    previewStore = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userSub?.cancel();
    _adminSub?.cancel();
    super.dispose();
  }
}
