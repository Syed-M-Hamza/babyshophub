import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/address_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../utils/pricing.dart';
import 'notification_service.dart';

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    NotificationService? notifications,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _notifications = notifications ?? NotificationService(firestore: firestore);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final NotificationService _notifications;

  Stream<List<ShopOrder>> watchForUser(String uid) {
    return _db.collection('orders').where('userId', isEqualTo: uid).snapshots().map(_sorted);
  }

  Stream<List<ShopOrder>> watchAll() {
    return _db.collection('orders').snapshots().map(_sorted);
  }

  List<ShopOrder> _sorted(QuerySnapshot<Map<String, dynamic>> snap) {
    final items = snap.docs.map((doc) => ShopOrder.fromDoc(doc.id, doc.data())).toList();
    items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return items;
  }

  Future<String> placeOrder({
    required String uid,
    required String customerName,
    required String phone,
    required Address address,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    if (items.isEmpty) {
      throw StateError('Your cart is empty.');
    }
    if (paymentMethod != 'cod' && paymentMethod != 'dummy_online') {
      throw StateError('Choose a payment method.');
    }
    final payload = items
        .map(
          (item) => {
            'productId': item.productId,
            'quantity': item.quantity,
          },
        )
        .toList();
    try {
      final callable = _functions.httpsCallable(
        'placeOrder',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );
      final result = await callable.call({
        'customerName': customerName,
        'phone': phone,
        'address': address.line,
        'city': address.city,
        'postalCode': address.postalCode,
        'paymentMethod': paymentMethod,
        'items': payload,
      });
      final raw = result.data;
      final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final orderId = data['orderId'] as String?;
      if (orderId == null || orderId.isEmpty) {
        throw StateError('The order service did not return an order id.');
      }
      return orderId;
    } on FirebaseFunctionsException catch (error) {
      const fallbackCodes = {'not-found', 'unavailable', 'unimplemented'};
      if (!fallbackCodes.contains(error.code)) {
        throw StateError(error.message ?? 'Could not place the order.');
      }
      return _placeWithTransaction(
        uid: uid,
        customerName: customerName,
        phone: phone,
        address: address,
        paymentMethod: paymentMethod,
        items: items,
      );
    }
  }

  Future<String> _placeWithTransaction({
    required String uid,
    required String customerName,
    required String phone,
    required Address address,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    final orderRef = _db.collection('orders').doc();
    final lockRef = _db.collection('checkout_locks').doc(uid);
    final orderNumber = 'BSH-${orderRef.id.substring(0, 8).toUpperCase()}';
    final isOnline = paymentMethod == 'dummy_online';

    await _db.runTransaction((txn) async {
      final lock = await txn.get(lockRef);
      final lockedAt = lock.data()?['updatedAt'];
      final lockedRecently = lockedAt is Timestamp && DateTime.now().difference(lockedAt.toDate()).inSeconds < 20;
      if (lock.data()?['status'] == 'processing' && lockedRecently) {
        throw StateError('Checkout is already in progress.');
      }
      txn.set(lockRef, {'status': 'processing', 'updatedAt': FieldValue.serverTimestamp()});
    });

    try {
      await _placeOrderDocuments(
        orderRef: orderRef,
        orderNumber: orderNumber,
        uid: uid,
        customerName: customerName,
        phone: phone,
        address: address,
        paymentMethod: paymentMethod,
        isOnline: isOnline,
        items: items,
      );
    } catch (error) {
      await lockRef.set({'status': 'idle', 'updatedAt': FieldValue.serverTimestamp()});
      rethrow;
    }
    await lockRef.set({
      'status': 'idle',
      'lastOrderId': orderRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notifications.push(
      userId: uid,
      title: 'Order placed',
      body: '$orderNumber has been received.',
      orderId: orderRef.id,
    );
    return orderRef.id;
  }

  Future<void> _placeOrderDocuments({
    required DocumentReference<Map<String, dynamic>> orderRef,
    required String orderNumber,
    required String uid,
    required String customerName,
    required String phone,
    required Address address,
    required String paymentMethod,
    required bool isOnline,
    required List<CartItem> items,
  }) {
    return _db.runTransaction((txn) async {
      final productSnaps = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final item in items) {
        productSnaps[item.productId] = await txn.get(_db.collection('products').doc(item.productId));
      }

      final lines = <OrderLine>[];
      for (final item in items) {
        final snap = productSnaps[item.productId]!;
        if (!snap.exists) {
          throw StateError('A product in your cart is no longer available.');
        }
        final product = Product.fromDoc(snap.id, snap.data() ?? {});
        if (!product.isAvailable || product.stock < item.quantity) {
          throw StateError('${product.productName} does not have enough stock.');
        }
        lines.add(
          OrderLine.fromProduct(
            productId: product.id,
            productName: product.productName,
            image: product.imageUrl,
            price: product.price,
            discount: product.discount,
            quantity: item.quantity,
          ),
        );
      }

      final subtotal = Pricing.subtotal(lines.map((line) => line.lineTotal));
      final delivery = Pricing.deliveryCharge(subtotal);
      txn.set(orderRef, {
        'orderId': orderRef.id,
        'orderNumber': orderNumber,
        'userId': uid,
        'customerName': customerName,
        'phone': phone,
        'address': address.line,
        'city': address.city,
        'postalCode': address.postalCode,
        'products': lines.map((line) => line.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryCharges': delivery,
        'totalAmount': subtotal + delivery,
        'paymentMethod': paymentMethod,
        'paymentStatus': isOnline ? 'paid' : 'pending',
        'orderStatus': isOnline ? 'confirmed' : 'placed',
        'pricingSource': 'client_transaction',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      for (final line in lines) {
        final snap = productSnaps[line.productId]!;
        final stock = (snap.data()?['stock'] as num?)?.round() ?? 0;
        txn.update(snap.reference, {'stock': stock - line.quantity, 'lastOrderId': orderRef.id});
      }
      for (final item in items) {
        txn.delete(_db.collection('carts').doc('${uid}_${item.productId}'));
      }
    });
  }

  Future<void> cancelOrder(ShopOrder order) async {
    if (!order.canCustomerCancel) {
      throw StateError('This order can no longer be cancelled.');
    }
    try {
      final callable = _functions.httpsCallable(
        'cancelOrder',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
      );
      await callable.call({'orderId': order.id});
    } on FirebaseFunctionsException catch (error) {
      const fallbackCodes = {'not-found', 'unavailable', 'unimplemented'};
      if (!fallbackCodes.contains(error.code)) {
        throw StateError(error.message ?? 'Could not cancel the order.');
      }
      await _cancelWithTransaction(order);
    }
    await _notifications.push(
      userId: order.userId,
      title: 'Order cancelled',
      body: '${order.orderNumber} was cancelled.',
      orderId: order.id,
    );
  }

  Future<void> _cancelWithTransaction(ShopOrder order) async {
    final orderRef = _db.collection('orders').doc(order.id);
    await _db.runTransaction((txn) async {
      final snap = await txn.get(orderRef);
      if (!snap.exists) throw StateError('Order not found.');
      final current = ShopOrder.fromDoc(snap.id, snap.data() ?? {});
      if (current.orderStatus == 'cancelled') return;
      if (current.orderStatus != 'placed' && current.orderStatus != 'confirmed') {
        throw StateError('This order can no longer be cancelled.');
      }
      final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final line in current.products) {
        productSnaps.add(await txn.get(_db.collection('products').doc(line.productId)));
      }
      txn.update(orderRef, {
        'orderStatus': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      for (var i = 0; i < current.products.length; i++) {
        final line = current.products[i];
        final productSnap = productSnaps[i];
        if (!productSnap.exists) continue;
        final stock = (productSnap.data()?['stock'] as num?)?.round() ?? 0;
        txn.update(productSnap.reference, {
          'stock': stock + line.quantity,
          'lastOrderId': order.id,
        });
      }
    });
  }

  Future<void> adminUpdate({
    required ShopOrder order,
    required String orderStatus,
    required String paymentStatus,
  }) async {
    final orderRef = _db.collection('orders').doc(order.id);
    final shouldRestore =
        orderStatus == 'cancelled' &&
        order.orderStatus != 'cancelled' &&
        order.orderStatus != 'delivered' &&
        order.orderStatus != 'shipped' &&
        order.orderStatus != 'out_for_delivery';

    if (shouldRestore) {
      await _db.runTransaction((txn) async {
        final snap = await txn.get(orderRef);
        final current = ShopOrder.fromDoc(snap.id, snap.data() ?? {});
        if (current.orderStatus == 'cancelled') return;
        final productSnaps = <DocumentSnapshot<Map<String, dynamic>>>[];
        for (final line in current.products) {
          productSnaps.add(await txn.get(_db.collection('products').doc(line.productId)));
        }
        txn.update(orderRef, {
          'orderStatus': 'cancelled',
          'paymentStatus': paymentStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        for (var i = 0; i < current.products.length; i++) {
          final productSnap = productSnaps[i];
          if (!productSnap.exists) continue;
          final stock = (productSnap.data()?['stock'] as num?)?.round() ?? 0;
          txn.update(productSnap.reference, {
            'stock': stock + current.products[i].quantity,
            'lastOrderId': order.id,
          });
        }
      });
    } else {
      await orderRef.update({
        'orderStatus': orderStatus,
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (order.orderStatus != orderStatus || order.paymentStatus != paymentStatus) {
      await _notifications.push(
        userId: order.userId,
        title: 'Order update',
        body: '${order.orderNumber} is now ${_label(orderStatus)}.',
        orderId: order.id,
      );
    }
  }

  String _label(String status) => status.replaceAll('_', ' ');
}
