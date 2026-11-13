import '../utils/parsers.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.addedAt,
  });

  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime? addedAt;

  factory CartItem.fromDoc(String id, Map<String, dynamic> data) {
    return CartItem(
      id: id,
      userId: (data['userId'] as String?) ?? '',
      productId: (data['productId'] as String?) ?? '',
      quantity: readInt(data['quantity'], 1),
      addedAt: readDate(data['addedAt']),
    );
  }
}
