import '../utils/formatters.dart';
import '../utils/parsers.dart';
import '../utils/pricing.dart';

class Product {
  const Product({
    required this.id,
    required this.productName,
    required this.brand,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.discount,
    required this.stock,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.popularity,
    required this.createdAt,
    this.priceLabel = '',
    this.cardColor = 0xFFFDECEC,
    this.group = '',
  });

  final String id;
  final String productName;
  final String brand;
  final String description;
  final String categoryId;
  final int price;
  final int discount;
  final int stock;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final int popularity;
  final DateTime? createdAt;
  final String priceLabel;
  final int cardColor;
  final String group;

  String get displayPrice => priceLabel.isNotEmpty ? priceLabel : formatMoney(salePrice);

  int get salePrice => Pricing.unitPrice(price, discount);
  bool get inStock => isAvailable && stock > 0;
  String get imageUrl => images.isEmpty ? '' : images.first;

  factory Product.fromDoc(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      productName: (data['productName'] as String?) ?? '',
      brand: (data['brand'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      categoryId: (data['categoryId'] as String?) ?? '',
      price: readInt(data['price']),
      discount: readInt(data['discount']),
      stock: readInt(data['stock']),
      images: readStringList(data['images']),
      rating: readDouble(data['rating']),
      reviewCount: readInt(data['reviewCount']),
      isAvailable: readBool(data['isAvailable'], true),
      popularity: readInt(data['popularity']),
      createdAt: readDate(data['createdAt']),
    );
  }

  }
