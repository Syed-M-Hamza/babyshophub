import '../utils/parsers.dart';

class Category {
  const Category({
    required this.id,
    required this.categoryName,
    required this.categoryImage,
    required this.createdAt,
  });

  final String id;
  final String categoryName;
  final String categoryImage;
  final DateTime? createdAt;

  factory Category.fromDoc(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      categoryName: (data['categoryName'] as String?) ?? '',
      categoryImage: (data['categoryImage'] as String?) ?? '',
      createdAt: readDate(data['createdAt']),
    );
  }
}
