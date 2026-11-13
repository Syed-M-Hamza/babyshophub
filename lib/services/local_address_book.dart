import 'package:flutter/foundation.dart';

import '../models/address_model.dart';

class LocalAddressBook extends ChangeNotifier {
  LocalAddressBook._();

  static final instance = LocalAddressBook._();

  final List<Address> items = [];

  void save(Address address) {
    final next = <Address>[];
    var found = false;
    for (final item in items) {
      if (item.id == address.id) {
        next.add(address);
        found = true;
      } else if (address.isDefault && item.isDefault) {
        next.add(item.copyWith(isDefault: false));
      } else {
        next.add(item);
      }
    }
    if (!found) next.insert(0, address);
    items
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void remove(String id) {
    items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
