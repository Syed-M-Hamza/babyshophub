import '../utils/parsers.dart';

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.email,
    required this.subject,
    required this.category,
    required this.message,
    required this.status,
    required this.adminResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String customerName;
  final String email;
  final String subject;
  final String category;
  final String message;
  final String status;
  final String adminResponse;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SupportTicket.fromDoc(String id, Map<String, dynamic> data) {
    return SupportTicket(
      id: id,
      userId: (data['userId'] as String?) ?? '',
      customerName: (data['customerName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      subject: (data['subject'] as String?) ?? '',
      category: (data['category'] as String?) ?? 'Other',
      message: (data['message'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'pending',
      adminResponse: (data['adminResponse'] as String?) ?? '',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }
}
