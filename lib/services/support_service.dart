import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/support_ticket_model.dart';

class SupportService {
  SupportService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<SupportTicket>> watchForUser(String uid) {
    return _db.collection('support_tickets').where('userId', isEqualTo: uid).snapshots().map(_map);
  }

  Stream<List<SupportTicket>> watchAll() {
    return _db.collection('support_tickets').snapshots().map(_map);
  }

  List<SupportTicket> _map(QuerySnapshot<Map<String, dynamic>> snap) {
    final items = snap.docs.map((doc) => SupportTicket.fromDoc(doc.id, doc.data())).toList();
    items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return items;
  }

  Future<String> submit({
    required String uid,
    required String customerName,
    required String email,
    required String category,
    required String subject,
    required String message,
  }) async {
    final ref = _db.collection('support_tickets').doc();
    await ref.set({
      'ticketId': ref.id,
      'userId': uid,
      'customerName': customerName.trim(),
      'email': email.trim(),
      'category': category,
      'subject': subject.trim(),
      'message': message.trim(),
      'status': 'pending',
      'adminResponse': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> respond({
    required String ticketId,
    required String status,
    required String response,
  }) {
    return _db.collection('support_tickets').doc(ticketId).update({
      'status': status,
      'adminResponse': response.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
