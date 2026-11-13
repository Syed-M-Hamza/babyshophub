import '../utils/parsers.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;
  final String? orderId;

  factory AppNotification.fromDoc(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      userId: (data['userId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      body: (data['body'] as String?) ?? '',
      read: readBool(data['read']),
      createdAt: readDate(data['createdAt']),
      orderId: data['orderId'] as String?,
    );
  }
}
