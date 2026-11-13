import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../navigation.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';

class PushMessaging {
  PushMessaging._();

  static bool _started = false;

  static Future<void> start(String uid) async {
    if (_started) return;
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) return;
    _started = true;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      await messaging.register();
      messaging.onRegistered.listen((token) {
        FirestoreService().saveFcmToken(uid, token);
      });
      FirebaseMessaging.onMessage.listen((message) {
        final text = message.notification?.title ?? message.notification?.body;
        final context = rootNavigatorKey.currentContext;
        if (text != null && context != null && context.mounted) {
          showMessage(context, text);
        }
      });
    } catch (_) {
      _started = false;
    }
  }
}
