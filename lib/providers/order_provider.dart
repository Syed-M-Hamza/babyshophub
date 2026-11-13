import 'dart:async';

import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderService? service}) : _service = service ?? OrderService();

  final OrderService _service;
  StreamSubscription<List<ShopOrder>>? _sub;
  int _binds = 0;

  List<ShopOrder> orders = [];
  bool loading = true;
  String? error;

  OrderService get service => _service;

  void retain(String uid) {
    _binds++;
    if (_sub != null) return;
    loading = true;
    _sub = _service.watchForUser(uid).listen(
      (value) {
        orders = value;
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
    orders = [];
  }

  ShopOrder? find(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
