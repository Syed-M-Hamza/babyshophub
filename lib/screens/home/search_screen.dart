import 'package:flutter/material.dart';

import '../../data/showcase_catalog.dart';
import '../../models/product_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/clay_product_card.dart';
import '../products/product_detail_screen.dart';

class ShopSearchScreen extends StatefulWidget {
  const ShopSearchScreen({super.key});

  @override
  State<ShopSearchScreen> createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends State<ShopSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final items = showcaseProducts.where((product) {
      return query.isEmpty || product.productName.toLowerCase().contains(query) || product.categoryId.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6EFE8),
      appBar: AppBar(backgroundColor: const Color(0xFFF6EFE8), title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB0A8A2)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: productColumns(constraints.maxWidth),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 268,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final Product product = items[index];
                return ClayProductCard(
                  product: product,
                  onOpen: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
                );
              },
            );
              },
            ),
          ),
        ],
      ),
    );
  }
}
