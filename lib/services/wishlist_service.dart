import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  WishlistService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<Set<String>> watchIds(String uid) {
    return _db.collection('wishlists').where('userId', isEqualTo: uid).snapshots().map((snap) {
      return snap.docs.map((doc) => (doc.data()['productId'] as String?) ?? '').where((id) => id.isNotEmpty).toSet();
    });
  }

  Future<void> add(String uid, String productId) {
    return _db.collection('wishlists').doc('${uid}_$productId').set({
      'userId': uid,
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(String uid, String productId) {
    return _db.collection('wishlists').doc('${uid}_$productId').delete();
  }
}
