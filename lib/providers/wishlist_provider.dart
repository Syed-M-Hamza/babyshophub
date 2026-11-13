import 'dart:async';

import 'package:flutter/material.dart';

import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider({WishlistService? service}) : _service = service ?? WishlistService();

  final WishlistService _service;
  StreamSubscription<Set<String>>? _sub;
  int _binds = 0;
  String? _uid;
  bool _keepLocal = false;

  Set<String> ids = {};

  bool contains(String productId) => ids.contains(productId);

  void retain(String uid) {
    _binds++;
    if (_uid == uid && _sub != null) return;
    _uid = uid;
    _sub?.cancel();
    _sub = _service.watchIds(uid).listen((value) {
      if (_keepLocal) return;
      ids = value;
      notifyListeners();
    });
  }

  void release() {
    _binds--;
    if (_binds > 0) return;
    _binds = 0;
    _sub?.cancel();
    _sub = null;
    _uid = null;
    ids = {};
  }

  Future<String?> toggle(String productId) async {
    final next = {...ids};
    if (next.contains(productId)) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    ids = next;
    _keepLocal = true;
    notifyListeners();
    final uid = _uid;
    if (uid == null) return null;
    try {
      if (next.contains(productId)) {
        await _service.add(uid, productId);
      } else {
        await _service.remove(uid, productId);
      }
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
