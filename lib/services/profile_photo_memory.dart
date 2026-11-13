import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class ProfilePhotoMemory extends ChangeNotifier {
  ProfilePhotoMemory._();

  static final instance = ProfilePhotoMemory._();

  Uint8List? bytes;

  void set(Uint8List value) {
    bytes = value;
    notifyListeners();
  }
}
