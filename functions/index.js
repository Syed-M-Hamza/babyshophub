const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

initializeApp();
const db = getFirestore();

function unitPrice(price, discount) {
  const raw = price * (100 - discount);
  return Math.round(raw / 100);
}

function deliveryCharge(subtotal) {
  if (subtotal <= 0 || subtotal >= 2000) return 0;
  return 150;
}

exports.placeOrder = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const uid = request.auth.uid;
  const data = request.data || {};
  const items = Array.isArray(data.items) ? data.items : [];
  const paymentMethod = data.paymentMethod;
  if (!items.length || items.length > 20) {
    throw new HttpsError('invalid-argument', 'Add between 1 and 20 products.');
  }
  if (paymentMethod !== 'cod' && paymentMethod !== 'dummy_online') {
    throw new HttpsError('invalid-argument', 'Choose a valid payment method.');
  }

  const userSnap = await db.collection('users').doc(uid).get();
  if (!userSnap.exists || userSnap.data().isActive === false) {
    throw new HttpsError('permission-denied', 'This account cannot place orders.');
  }

  const orderRef = db.collection('orders').doc();
  const orderNumber = `BSH-${orderRef.id.substring(0, 8).toUpperCase()}`;

  await db.runTransaction(async (txn) => {
    const lines = [];
    const snaps = [];
    for (const item of items) {
      const productId = String(item.productId || '');
      const quantity = Number(item.quantity);
      if (!productId || !Number.isInteger(quantity) || quantity < 1 || quantity > 20) {
        throw new HttpsError('invalid-argument', 'Each item needs a valid quantity.');
      }
      const snap = await txn.get(db.collection('products').doc(productId));
      if (!snap.exists || snap.data().isAvailable === false || snap.data().stock < quantity) {
        throw new HttpsError('failed-precondition', 'A product is unavailable or out of stock.');
      }
      snaps.push({ snap, quantity });
    }

    for (const entry of snaps) {
      const product = entry.snap.data();
      const unit = unitPrice(product.price, product.discount);
      lines.push({
        productId: entry.snap.id,
        productName: product.productName,
        image: Array.isArray(product.images) && product.images.length ? product.images[0] : '',
        price: product.price,
        discount: product.discount,
        unitPrice: unit,
        quantity: entry.quantity,
        lineTotal: unit * entry.quantity,
      });
    }

    const subtotal = lines.reduce((sum, line) => sum + line.lineTotal, 0);
    const delivery = deliveryCharge(subtotal);
    const online = paymentMethod === 'dummy_online';
    txn.set(orderRef, {
      orderId: orderRef.id,
      orderNumber,
      userId: uid,
      customerName: String(data.customerName || ''),
      phone: String(data.phone || ''),
      address: String(data.address || ''),
      city: String(data.city || ''),
      postalCode: String(data.postalCode || ''),
      products: lines,
      subtotal,
      deliveryCharges: delivery,
      totalAmount: subtotal + delivery,
      paymentMethod,
      paymentStatus: online ? 'paid' : 'pending',
      orderStatus: online ? 'confirmed' : 'placed',
      pricingSource: 'cloud_function',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    for (const entry of snaps) {
      txn.update(entry.snap.ref, {
        stock: entry.snap.data().stock - entry.quantity,
        lastOrderId: orderRef.id,
      });
      txn.delete(db.collection('carts').doc(`${uid}_${entry.snap.id}`));
    }

    txn.set(db.collection('notifications').doc(), {
      userId: uid,
      title: 'Order placed',
      body: `${orderNumber} has been received.`,
      read: false,
      orderId: orderRef.id,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  return { orderId: orderRef.id, orderNumber };
});

exports.cancelOrder = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');
  const uid = request.auth.uid;
  const orderId = String((request.data || {}).orderId || '');
  if (!orderId) throw new HttpsError('invalid-argument', 'Order id is required.');
  const orderRef = db.collection('orders').doc(orderId);

  await db.runTransaction(async (txn) => {
    const orderSnap = await txn.get(orderRef);
    if (!orderSnap.exists || orderSnap.data().userId !== uid) {
      throw new HttpsError('permission-denied', 'You cannot cancel this order.');
    }
    const order = orderSnap.data();
    if (!['placed', 'confirmed'].includes(order.orderStatus)) {
      throw new HttpsError('failed-precondition', 'This order can no longer be cancelled.');
    }
    const productSnaps = [];
    for (const line of order.products || []) {
      productSnaps.push(await txn.get(db.collection('products').doc(line.productId)));
    }
    txn.update(orderRef, { orderStatus: 'cancelled', updatedAt: FieldValue.serverTimestamp() });
    order.products.forEach((line, index) => {
      const productSnap = productSnaps[index];
      if (!productSnap.exists) return;
      txn.update(productSnap.ref, { stock: productSnap.data().stock + line.quantity, lastOrderId: orderId });
    });
  });

  await db.collection('notifications').add({
    userId: uid,
    title: 'Order cancelled',
    body: 'Your order was cancelled.',
    read: false,
    orderId,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});
