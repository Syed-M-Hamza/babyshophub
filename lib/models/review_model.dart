import '../utils/parsers.dart';

class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  factory Review.fromDoc(String id, Map<String, dynamic> data) {
    return Review(
      id: id,
      productId: (data['productId'] as String?) ?? '',
      userId: (data['userId'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? 'Customer',
      rating: readInt(data['rating']),
      comment: (data['comment'] as String?) ?? '',
      createdAt: readDate(data['createdAt']),
    );
  }
}
