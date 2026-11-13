import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/clay_product_card.dart';
import '../products/product_detail_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.title, required this.products});

  final String title;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        backgroundColor: AppColors.softCream,
        title: Text(title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: productColumns(constraints.maxWidth),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 268,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ClayProductCard(
            product: product,
            onOpen: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
          );
        },
      );
        },
      ),
    );
  }
}
