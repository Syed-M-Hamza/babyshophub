import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/app_constants.dart';

class SeedService {
  SeedService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String> seedCatalog() async {
    final existing = await _db.collection('products').limit(1).get();
    if (existing.docs.isNotEmpty) {
      return 'The catalog already has products, so sample data was not added again.';
    }

    for (final category in _categories) {
      await _db.collection('categories').doc(category.id).set({
        'categoryId': category.id,
        'categoryName': category.name,
        'categoryImage': category.image,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    for (final product in _products) {
      final ref = _db.collection('products').doc(product.id);
      await ref.set({
        'productId': ref.id,
        'productName': product.name,
        'brand': product.brand,
        'description': product.description,
        'categoryId': product.categoryId,
        'price': product.price,
        'discount': product.discount,
        'stock': product.stock,
        'images': product.images,
        'rating': 0,
        'reviewCount': 0,
        'isAvailable': true,
        'popularity': product.popularity,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await _db.collection('sellers').doc(AppConstants.storeSellerId).set({
      'name': 'BabyShopHub',
      'description':
          'BabyShopHub is a single-store baby boutique. We pack clothing, care, feeding and play essentials for everyday family life.',
      'city': 'Karachi',
      'email': 'hello@babyshophub.app',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return 'Sample categories, the store profile and ${ _products.length } products were added.';
  }
}

class _SeedCategory {
  const _SeedCategory(this.id, this.name, this.image);
  final String id;
  final String name;
  final String image;
}

class _SeedProduct {
  const _SeedProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.discount,
    required this.stock,
    required this.popularity,
    required this.images,
  });

  final String id;
  final String name;
  final String brand;
  final String description;
  final String categoryId;
  final int price;
  final int discount;
  final int stock;
  final int popularity;
  final List<String> images;
}

const _imgBaby = 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=900&q=80';
const _imgClothes = 'https://images.unsplash.com/photo-1522771930-78848d9293e8?auto=format&fit=crop&w=900&q=80';
const _imgSoft = 'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=900&q=80';
const _imgToys = 'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?auto=format&fit=crop&w=900&q=80';
const _imgCare = 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=900&q=80';
const _imgBottle = 'https://images.unsplash.com/photo-1584839404042-8bc21d240e91?auto=format&fit=crop&w=900&q=80';

const _categories = [
  _SeedCategory('clothing', 'Baby Clothing', _imgClothes),
  _SeedCategory('diapers', 'Baby Diapers', _imgSoft),
  _SeedCategory('food', 'Baby Food', _imgBottle),
  _SeedCategory('toys', 'Baby Toys', _imgToys),
  _SeedCategory('skincare', 'Baby Skincare', _imgCare),
  _SeedCategory('feeding', 'Baby Feeding', _imgBottle),
  _SeedCategory('bath', 'Baby Bath Products', _imgCare),
  _SeedCategory('accessories', 'Baby Accessories', _imgBaby),
  _SeedCategory('bedding', 'Baby Bedding', _imgSoft),
  _SeedCategory('health', 'Baby Health and Care', _imgCare),
];

const _products = [
  _SeedProduct(
    id: 'cloud-romper',
    name: 'Cloud Cotton Romper',
    brand: 'TinyNest',
    description: 'A breathable cotton romper with snap buttons for easy changes and a soft neckline for everyday wear.',
    categoryId: 'clothing',
    price: 2400,
    discount: 10,
    stock: 24,
    popularity: 92,
    images: [_imgClothes, _imgBaby],
  ),
  _SeedProduct(
    id: 'peach-set',
    name: 'Peach Knit Two-Piece',
    brand: 'SoftPeach',
    description: 'A lightweight knit top and trouser set in a gentle peach tone, made for naps and outings.',
    categoryId: 'clothing',
    price: 3200,
    discount: 0,
    stock: 18,
    popularity: 74,
    images: [_imgSoft],
  ),
  _SeedProduct(
    id: 'dry-nights',
    name: 'Dry Nights Diapers',
    brand: 'MamaCare',
    description: 'Soft overnight diapers with a flexible waist and a wetness indicator for quick checks.',
    categoryId: 'diapers',
    price: 1800,
    discount: 15,
    stock: 40,
    popularity: 98,
    images: [_imgBaby],
  ),
  _SeedProduct(
    id: 'day-pants',
    name: 'Daytime Diaper Pants',
    brand: 'LittleCloud',
    description: 'Pull-up diaper pants designed for active babies who are learning to move.',
    categoryId: 'diapers',
    price: 1650,
    discount: 0,
    stock: 36,
    popularity: 80,
    images: [_imgSoft],
  ),
  _SeedProduct(
    id: 'oat-cereal',
    name: 'Gentle Oat Cereal',
    brand: 'Bubbly',
    description: 'Smooth oat cereal for early spoon feeding. No added sugar, and easy to mix with milk.',
    categoryId: 'food',
    price: 890,
    discount: 0,
    stock: 30,
    popularity: 70,
    images: [_imgBottle],
  ),
  _SeedProduct(
    id: 'fruit-puree',
    name: 'Apple Pear Puree',
    brand: 'Bubbly',
    description: 'A mild fruit puree pouch for supervised snacking away from home.',
    categoryId: 'food',
    price: 450,
    discount: 0,
    stock: 50,
    popularity: 66,
    images: [_imgCare],
  ),
  _SeedProduct(
    id: 'stack-rings',
    name: 'Pastel Stacking Rings',
    brand: 'CozyCub',
    description: 'Rounded stacking rings in quiet pastel colours that are easy for small hands to grasp.',
    categoryId: 'toys',
    price: 1500,
    discount: 20,
    stock: 22,
    popularity: 88,
    images: [_imgToys],
  ),
  _SeedProduct(
    id: 'knit-bear',
    name: 'Knit Companion Bear',
    brand: 'CozyCub',
    description: 'A soft knit bear for cuddles and nursery shelves, with stitched features and no loose parts.',
    categoryId: 'toys',
    price: 2100,
    discount: 0,
    stock: 16,
    popularity: 77,
    images: [_imgToys, _imgSoft],
  ),
  _SeedProduct(
    id: 'lotion',
    name: 'Daily Soft Lotion',
    brand: 'MamaCare',
    description: 'A light, fragrance-free lotion for dry cheeks, elbows and knees after bath time.',
    categoryId: 'skincare',
    price: 1200,
    discount: 10,
    stock: 28,
    popularity: 73,
    images: [_imgCare],
  ),
  _SeedProduct(
    id: 'balm',
    name: 'Calm Cream Balm',
    brand: 'MamaCare',
    description: 'A thick balm for dry patches. Use a small amount and let it sink in before dressing.',
    categoryId: 'skincare',
    price: 980,
    discount: 0,
    stock: 26,
    popularity: 61,
    images: [_imgCare],
  ),
  _SeedProduct(
    id: 'glass-bottle',
    name: 'Soft Flow Bottle',
    brand: 'LittleCloud',
    description: 'A wide-neck bottle with a slow-flow teat and measurement marks that are easy to read.',
    categoryId: 'feeding',
    price: 1450,
    discount: 0,
    stock: 20,
    popularity: 84,
    images: [_imgBottle],
  ),
  _SeedProduct(
    id: 'bowl-set',
    name: 'Suction Bowl Set',
    brand: 'TinyNest',
    description: 'Two suction bowls and a soft spoon that stay put while your baby learns to self-feed.',
    categoryId: 'feeding',
    price: 1750,
    discount: 10,
    stock: 19,
    popularity: 69,
    images: [_imgBottle, _imgBaby],
  ),
  _SeedProduct(
    id: 'wash',
    name: 'Mild Bath Wash',
    brand: 'SoftPeach',
    description: 'A tear-free wash for hair and body with a light clean scent and no harsh lather.',
    categoryId: 'bath',
    price: 1100,
    discount: 0,
    stock: 32,
    popularity: 64,
    images: [_imgCare],
  ),
  _SeedProduct(
    id: 'hood-towel',
    name: 'Hooded Bath Towel',
    brand: 'SoftPeach',
    description: 'An absorbent hooded towel with a gentle loop texture for wrapping up after a bath.',
    categoryId: 'bath',
    price: 2600,
    discount: 20,
    stock: 14,
    popularity: 81,
    images: [_imgSoft],
  ),
  _SeedProduct(
    id: 'sun-hat',
    name: 'Brim Sun Hat',
    brand: 'TinyNest',
    description: 'A soft brim hat with a chin tie that stays comfortable on walks and in the stroller.',
    categoryId: 'accessories',
    price: 900,
    discount: 0,
    stock: 21,
    popularity: 58,
    images: [_imgBaby],
  ),
  _SeedProduct(
    id: 'bib-trio',
    name: 'Catch-All Bib Trio',
    brand: 'LittleCloud',
    description: 'Three easy-wipe bibs with a deep pocket for spoon-feeding messes.',
    categoryId: 'accessories',
    price: 750,
    discount: 0,
    stock: 34,
    popularity: 63,
    images: [_imgClothes],
  ),
  _SeedProduct(
    id: 'crib-sheet',
    name: 'Fitted Crib Sheet',
    brand: 'CozyCub',
    description: 'A jersey crib sheet with a deep elastic edge that stays tucked through the night.',
    categoryId: 'bedding',
    price: 1600,
    discount: 0,
    stock: 17,
    popularity: 72,
    images: [_imgSoft],
  ),
  _SeedProduct(
    id: 'muslin',
    name: 'Muslin Swaddle Pair',
    brand: 'CozyCub',
    description: 'Two breathable muslin swaddles that work as blankets, nursing covers or stroller shades.',
    categoryId: 'bedding',
    price: 2200,
    discount: 15,
    stock: 18,
    popularity: 86,
    images: [_imgSoft, _imgBaby],
  ),
  _SeedProduct(
    id: 'thermometer',
    name: 'Quick Read Thermometer',
    brand: 'MamaCare',
    description: 'A digital thermometer with a clear display for home temperature checks.',
    categoryId: 'health',
    price: 1900,
    discount: 0,
    stock: 15,
    popularity: 67,
    images: [_imgCare],
  ),
  _SeedProduct(
    id: 'nail-kit',
    name: 'Gentle Nail Care Kit',
    brand: 'MamaCare',
    description: 'Rounded baby nail scissors, a file and a clipper stored in a small zip case.',
    categoryId: 'health',
    price: 850,
    discount: 0,
    stock: 25,
    popularity: 55,
    images: [_imgBaby],
  ),
];
