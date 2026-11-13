import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<AppNotification>> watch(String uid) {
    return _db.collection('notifications').where('userId', isEqualTo: uid).snapshots().map((snap) {
      final items = snap.docs.map((doc) => AppNotification.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return items;
    });
  }

  Future<void> push({
    required String userId,
    required String title,
    required String body,
    String? orderId,
  }) {
    final ref = _db.collection('notifications').doc();
    return ref.set({
      'notificationId': ref.id,
      'userId': userId,
      'title': title,
      'body': body,
      'read': false,
      'orderId': orderId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markRead(String id) {
    return _db.collection('notifications').doc(id).update({'read': true});
  }
}
