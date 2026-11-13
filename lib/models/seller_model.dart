import '../utils/parsers.dart';

class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.email,
  });

  final String id;
  final String name;
  final String description;
  final String city;
  final String email;

  factory Seller.fromDoc(String id, Map<String, dynamic> data) {
    return Seller(
      id: id,
      name: (data['name'] as String?) ?? 'BabyShopHub',
      description: (data['description'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
    );
  }
}

class SellerFeedback {
  const SellerFeedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  factory SellerFeedback.fromDoc(String id, Map<String, dynamic> data) {
    return SellerFeedback(
      id: id,
      userId: (data['userId'] as String?) ?? '',
      userName: (data['userName'] as String?) ?? 'Customer',
      rating: readInt(data['rating']),
      comment: (data['comment'] as String?) ?? '',
      createdAt: readDate(data['createdAt']),
    );
  }
}
