import '../utils/parsers.dart';
import '../utils/pricing.dart';

class OrderLine {
  const OrderLine({
    required this.productId,
    required this.productName,
    required this.image,
    required this.price,
    required this.discount,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final String productId;
  final String productName;
  final String image;
  final int price;
  final int discount;
  final int unitPrice;
  final int quantity;
  final int lineTotal;

  factory OrderLine.fromProduct({
    required String productId,
    required String productName,
    required String image,
    required int price,
    required int discount,
    required int quantity,
  }) {
    final unit = Pricing.unitPrice(price, discount);
    return OrderLine(
      productId: productId,
      productName: productName,
      image: image,
      price: price,
      discount: discount,
      unitPrice: unit,
      quantity: quantity,
      lineTotal: unit * quantity,
    );
  }

  factory OrderLine.fromMap(Map<String, dynamic> data) {
    return OrderLine(
      productId: (data['productId'] as String?) ?? '',
      productName: (data['productName'] as String?) ?? '',
      image: (data['image'] as String?) ?? '',
      price: readInt(data['price']),
      discount: readInt(data['discount']),
      unitPrice: readInt(data['unitPrice']),
      quantity: readInt(data['quantity'], 1),
      lineTotal: readInt(data['lineTotal']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'image': image,
      'price': price,
      'discount': discount,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
    };
  }
}

class ShopOrder {
  const ShopOrder({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.products,
    required this.subtotal,
    required this.deliveryCharges,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.pricingSource,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNumber;
  final String userId;
  final String customerName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final List<OrderLine> products;
  final int subtotal;
  final int deliveryCharges;
  final int totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String pricingSource;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get canCustomerCancel => orderStatus == 'placed' || orderStatus == 'confirmed';

  factory ShopOrder.fromDoc(String id, Map<String, dynamic> data) {
    final rawLines = data['products'];
    final lines = <OrderLine>[];
    if (rawLines is List) {
      for (final item in rawLines) {
        if (item is Map<String, dynamic>) {
          lines.add(OrderLine.fromMap(item));
        } else if (item is Map) {
          lines.add(OrderLine.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ShopOrder(
      id: id,
      orderNumber: (data['orderNumber'] as String?) ?? id,
      userId: (data['userId'] as String?) ?? '',
      customerName: (data['customerName'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      address: (data['address'] as String?) ?? '',
      city: (data['city'] as String?) ?? '',
      postalCode: (data['postalCode'] as String?) ?? '',
      products: lines,
      subtotal: readInt(data['subtotal']),
      deliveryCharges: readInt(data['deliveryCharges']),
      totalAmount: readInt(data['totalAmount']),
      paymentMethod: (data['paymentMethod'] as String?) ?? 'cod',
      paymentStatus: (data['paymentStatus'] as String?) ?? 'pending',
      orderStatus: (data['orderStatus'] as String?) ?? 'placed',
      pricingSource: (data['pricingSource'] as String?) ?? 'client_transaction',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
    );
  }
}
