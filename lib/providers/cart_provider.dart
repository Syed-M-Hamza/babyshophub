import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../utils/app_constants.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({CartService? service}) : _service = service ?? CartService();

  final CartService _service;
  StreamSubscription<List<CartItem>>? _sub;
  int _binds = 0;
  String? _uid;
  bool _keepLocal = false;

  List<CartItem> items = [];
  bool loading = false;
  String? error;

  int get count => items.fold(0, (sum, item) => sum + item.quantity);

  void retain(String uid) {
    _binds++;
    if (_uid == uid && _sub != null) return;
    _uid = uid;
    _sub?.cancel();
    loading = true;
    _sub = _service.watch(uid).listen(
      (value) {
        if (_keepLocal) return;
        items = value;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object err) {
        error = err.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  void release() {
    _binds--;
    if (_binds > 0) return;
    _binds = 0;
    _sub?.cancel();
    _sub = null;
    _uid = null;
    items = [];
  }

  CartItem? itemFor(String productId) {
    for (final item in items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  void _saveLocal(String productId, int quantity) {
    final next = items.where((item) => item.productId != productId).toList();
    if (quantity > 0) {
      next.add(CartItem(id: productId, userId: _uid ?? 'guest', productId: productId, quantity: quantity, addedAt: DateTime.now()));
    }
    items = next;
    loading = false;
    error = null;
    _keepLocal = true;
    notifyListeners();
  }

  Future<String?> add(Product product, {int quantity = 1}) async {
    if (!product.inStock) return '${product.productName} is out of stock.';
    final existing = itemFor(product.id)?.quantity ?? 0;
    final next = existing + quantity;
    if (next > product.stock) return 'Only ${product.stock} available.';
    if (next > AppConstants.maxCartQuantity) return 'You can add up to ${AppConstants.maxCartQuantity} of one product.';
    _saveLocal(product.id, next);
    final uid = _uid;
    if (uid == null) return null;
    try {
      await _service.setQuantity(uid: uid, productId: product.id, quantity: next);
    } catch (_) {}
    return null;
  }

  Future<String?> setQuantity(Product product, int quantity) async {
    if (quantity > product.stock) return 'Only ${product.stock} available.';
    if (quantity > AppConstants.maxCartQuantity) {
      return 'Maximum quantity is ${AppConstants.maxCartQuantity}.';
    }
    _saveLocal(product.id, quantity);
    final uid = _uid;
    if (uid == null) return null;
    try {
      await _service.setQuantity(uid: uid, productId: product.id, quantity: quantity);
    } catch (_) {}
    return null;
  }

  Future<void> remove(String productId) async {
    _saveLocal(productId, 0);
    final uid = _uid;
    if (uid == null) return;
    try {
      await _service.remove(uid, productId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
