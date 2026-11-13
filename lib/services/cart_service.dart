import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_model.dart';
import '../utils/app_constants.dart';

class CartService {
  CartService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<CartItem>> watch(String uid) {
    return _db.collection('carts').where('userId', isEqualTo: uid).snapshots().map((snap) {
      final items = snap.docs.map((doc) => CartItem.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => (b.addedAt ?? DateTime(2000)).compareTo(a.addedAt ?? DateTime(2000)));
      return items;
    });
  }

  Future<void> setQuantity({
    required String uid,
    required String productId,
    required int quantity,
  }) async {
    final ref = _db.collection('carts').doc('${uid}_$productId');
    if (quantity <= 0) {
      await ref.delete();
      return;
    }
    final safeQty = quantity.clamp(1, AppConstants.maxCartQuantity);
    await ref.set({
      'userId': uid,
      'productId': productId,
      'quantity': safeQty,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove(String uid, String productId) {
    return _db.collection('carts').doc('${uid}_$productId').delete();
  }

  Future<void> clear(String uid) async {
    final snap = await _db.collection('carts').where('userId', isEqualTo: uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
