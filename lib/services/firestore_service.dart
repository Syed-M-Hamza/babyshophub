import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/address_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';
import '../models/seller_model.dart';
import '../models/user_model.dart';
import '../utils/app_constants.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  FirebaseFirestore get db => _db;

  Stream<AppUser?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromDoc(snap);
    });
  }

  Stream<bool> watchAdmin(String uid) {
    return _db.collection('admins').doc(uid).snapshots().map((snap) => snap.exists);
  }

  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
    String? profileImage,
  }) {
    final data = <String, dynamic>{'fullName': fullName.trim(), 'phone': phone.trim()};
    if (profileImage != null) data['profileImage'] = profileImage;
    return _db.collection('users').doc(uid).update(data);
  }

  Future<void> saveFcmToken(String uid, String token) {
    return _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  Stream<List<Category>> watchCategories() {
    return _db.collection('categories').snapshots().map((snap) {
      final items = snap.docs.map((doc) => Category.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => a.categoryName.compareTo(b.categoryName));
      return items;
    });
  }

  Stream<List<Product>> watchProducts() {
    return _db.collection('products').snapshots().map((snap) {
      return snap.docs.map((doc) => Product.fromDoc(doc.id, doc.data())).toList();
    });
  }

  Future<void> saveCategory({String? id, required String name, required String image}) async {
    final ref = id == null ? _db.collection('categories').doc() : _db.collection('categories').doc(id);
    if (id == null) {
      await ref.set({
        'categoryId': ref.id,
        'categoryName': name.trim(),
        'categoryImage': image.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    await ref.update({'categoryName': name.trim(), 'categoryImage': image.trim()});
  }

  Future<void> deleteCategory(String id) => _db.collection('categories').doc(id).delete();

  Future<void> saveProduct({
    String? id,
    required String name,
    required String brand,
    required String description,
    required String categoryId,
    required int price,
    required int discount,
    required int stock,
    required List<String> images,
    required bool isAvailable,
    required int popularity,
  }) async {
    final ref = id == null ? _db.collection('products').doc() : _db.collection('products').doc(id);
    final data = <String, dynamic>{
      'productId': ref.id,
      'productName': name.trim(),
      'brand': brand.trim(),
      'description': description.trim(),
      'categoryId': categoryId,
      'price': price,
      'discount': discount,
      'stock': stock,
      'images': images,
      'isAvailable': isAvailable,
      'popularity': popularity,
    };
    if (id == null) {
      data['rating'] = 0;
      data['reviewCount'] = 0;
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
    } else {
      await ref.update(data);
    }
  }

  Future<void> deleteProduct(String id) => _db.collection('products').doc(id).delete();

  Stream<List<Address>> watchAddresses(String uid) {
    return _db.collection('users').doc(uid).collection('addresses').snapshots().map((snap) {
      final items = snap.docs.map((doc) => Address.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) {
        if (a.isDefault == b.isDefault) return a.label.compareTo(b.label);
        return a.isDefault ? -1 : 1;
      });
      return items;
    });
  }

  String newAddressId(String uid) {
    return _db.collection('users').doc(uid).collection('addresses').doc().id;
  }

  Future<void> saveAddress(String uid, Address address) {
    final parent = _db.collection('users').doc(uid).collection('addresses');
    final ref = address.id.isEmpty ? parent.doc() : parent.doc(address.id);
    return ref.set(address.toMap());
  }

  Future<void> deleteAddress(String uid, String addressId) {
    return _db.collection('users').doc(uid).collection('addresses').doc(addressId).delete();
  }

  Stream<List<Review>> watchProductReviews(String productId) {
    return _db.collection('reviews').where('productId', isEqualTo: productId).snapshots().map((snap) {
      final items = snap.docs.map((doc) => Review.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return items;
    });
  }

  Stream<List<Review>> watchAllReviews() {
    return _db.collection('reviews').snapshots().map((snap) {
      final items = snap.docs.map((doc) => Review.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return items;
    });
  }

  Future<void> addReview({
    required Product product,
    required String uid,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    final reviewRef = _db.collection('reviews').doc('${uid}_${product.id}');
    final productRef = _db.collection('products').doc(product.id);
    await _db.runTransaction((txn) async {
      final productSnap = await txn.get(productRef);
      final reviewSnap = await txn.get(reviewRef);
      if (!productSnap.exists) {
        throw StateError('This product is no longer available.');
      }
      if (reviewSnap.exists) {
        throw StateError('You have already reviewed this product.');
      }
      final current = Product.fromDoc(productSnap.id, productSnap.data() ?? {});
      final newCount = current.reviewCount + 1;
      final newRating = ((current.rating * current.reviewCount) + rating) / newCount;
      txn.set(reviewRef, {
        'reviewId': reviewRef.id,
        'productId': product.id,
        'userId': uid,
        'userName': userName,
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.update(productRef, {'rating': newRating, 'reviewCount': newCount});
    });
  }

  Future<void> deleteReview(Review review) async {
    final reviewRef = _db.collection('reviews').doc(review.id);
    final productRef = _db.collection('products').doc(review.productId);
    final remaining = await _db.collection('reviews').where('productId', isEqualTo: review.productId).get();
    final others = remaining.docs.where((doc) => doc.id != review.id).toList();
    double rating = 0;
    if (others.isNotEmpty) {
      final total = others.fold<int>(0, (runningTotal, doc) => runningTotal + (doc.data()['rating'] as num).round());
      rating = total / others.length;
    }
    final batch = _db.batch();
    batch.delete(reviewRef);
    batch.update(productRef, {'rating': rating, 'reviewCount': others.length});
    await batch.commit();
  }

  Stream<List<AppUser>> watchCustomers() {
    return _db.collection('users').snapshots().map((snap) {
      final items = snap.docs.map(AppUser.fromDoc).toList();
      items.sort((a, b) => a.fullName.compareTo(b.fullName));
      return items;
    });
  }

  Future<void> setUserActive(String uid, bool active) {
    return _db.collection('users').doc(uid).update({'isActive': active});
  }

  Stream<Seller?> watchSeller() {
    return _db.collection('sellers').doc(AppConstants.storeSellerId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return Seller.fromDoc(snap.id, snap.data() ?? {});
    });
  }

  Stream<List<SellerFeedback>> watchSellerFeedback() {
    return _db.collection('seller_feedback').snapshots().map((snap) {
      final items = snap.docs.map((doc) => SellerFeedback.fromDoc(doc.id, doc.data())).toList();
      items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      return items;
    });
  }

  Future<void> saveSellerFeedback({
    required String uid,
    required String userName,
    required int rating,
    required String comment,
  }) {
    return _db.collection('seller_feedback').doc(uid).set({
      'userId': uid,
      'sellerId': AppConstants.storeSellerId,
      'userName': userName,
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
