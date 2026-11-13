import 'dart:async';

import 'package:flutter/material.dart';

import '../data/showcase_catalog.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

enum ProductSort { popularity, priceLow, priceHigh, newest, rating }

class ProductProvider extends ChangeNotifier {
  ProductProvider({FirestoreService? firestore}) : _firestore = firestore ?? FirestoreService();

  final FirestoreService _firestore;
  StreamSubscription<List<Product>>? _productSub;
  StreamSubscription<List<Category>>? _categorySub;
  int _binds = 0;

  List<Product> products = List<Product>.of(showcaseProducts);
  List<Category> categories = List<Category>.of(showcaseCategories);
  bool loading = false;
  String? error;

  String query = '';
  String? categoryId;
  int? minPrice;
  int? maxPrice;
  int minRating = 0;
  ProductSort sort = ProductSort.popularity;

  void retain() {
    _binds++;
    if (_productSub != null) return;
    loading = true;
    _productSub = _firestore.watchProducts().listen(
      (items) {
        final remote = items.where((product) => !showcaseIds.contains(product.id));
        products = [...showcaseProducts, ...remote];
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (Object _) {
        products = List<Product>.of(showcaseProducts);
        loading = false;
        error = null;
        notifyListeners();
      },
    );
    _categorySub = _firestore.watchCategories().listen((items) {
      if (items.isEmpty) {
        categories = List<Category>.of(showcaseCategories);
      } else {
        categories = items;
      }
      notifyListeners();
    });
  }

  void release() {
    _binds--;
    if (_binds > 0) return;
    _binds = 0;
    _productSub?.cancel();
    _categorySub?.cancel();
    _productSub = null;
    _categorySub = null;
  }

  Product? find(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    for (final product in showcaseProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  Category? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  String categoryName(String id) => categoryById(id)?.categoryName ?? 'Baby products';

  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  void applyFilters({
    String? categoryId,
    int? minPrice,
    int? maxPrice,
    int? minRating,
    ProductSort? sort,
    bool clearCategory = false,
  }) {
    if (clearCategory) {
      this.categoryId = null;
    } else if (categoryId != null) {
      this.categoryId = categoryId;
    }
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    if (minRating != null) this.minRating = minRating;
    if (sort != null) this.sort = sort;
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    categoryId = null;
    minPrice = null;
    maxPrice = null;
    minRating = 0;
    sort = ProductSort.popularity;
    notifyListeners();
  }

  List<Product> get filtered {
    final text = query.trim().toLowerCase();
    final result = products.where((product) {
      final category = categoryName(product.categoryId).toLowerCase();
      final matchesText =
          text.isEmpty ||
          product.productName.toLowerCase().contains(text) ||
          product.brand.toLowerCase().contains(text) ||
          category.contains(text);
      final matchesCategory = categoryId == null || product.categoryId == categoryId;
      final matchesMin = minPrice == null || product.salePrice >= minPrice!;
      final matchesMax = maxPrice == null || product.salePrice <= maxPrice!;
      final matchesRating = minRating <= 0 || product.rating >= minRating;
      return matchesText && matchesCategory && matchesMin && matchesMax && matchesRating;
    }).toList();

    result.sort((a, b) {
      switch (sort) {
        case ProductSort.priceLow:
          return a.salePrice.compareTo(b.salePrice);
        case ProductSort.priceHigh:
          return b.salePrice.compareTo(a.salePrice);
        case ProductSort.newest:
          return (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000));
        case ProductSort.rating:
          return b.rating.compareTo(a.rating);
        case ProductSort.popularity:
          return b.popularity.compareTo(a.popularity);
      }
    });
    return result;
  }

  List<Product> get suggestions {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return const [];
    return products
        .where(
          (product) =>
              product.productName.toLowerCase().contains(text) || product.brand.toLowerCase().contains(text),
        )
        .take(6)
        .toList();
  }

  List<Product> _top(List<Product> source, int count) => source.take(count).toList();

  List<Product> get featured => _top(
    [...products]..sort((a, b) => b.popularity.compareTo(a.popularity)),
    8,
  );

  List<Product> get popular {
    final sorted = [...products]..sort((a, b) => b.popularity.compareTo(a.popularity));
    if (sorted.length <= 4) return _top(sorted, 8);
    return sorted.skip(2).take(8).toList();
  }

  List<Product> get newArrivals => _top(
    [...products]..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000))),
    8,
  );

  List<Product> get bestSellers => _top(
    [...products]..sort((a, b) => b.popularity.compareTo(a.popularity)),
    8,
  );

  List<Product> get specialOffers => _top(products.where((product) => product.discount > 0).toList(), 8);

  List<Product> get recommended => _top(
    [...products]..sort((a, b) {
      final rating = b.rating.compareTo(a.rating);
      if (rating != 0) return rating;
      return b.popularity.compareTo(a.popularity);
    }),
    8,
  );

  @override
  void dispose() {
    _productSub?.cancel();
    _categorySub?.cancel();
    super.dispose();
  }
}
