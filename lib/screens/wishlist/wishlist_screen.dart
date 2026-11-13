import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/loading_widget.dart';
import '../home/customer_shell.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final catalog = context.watch<ProductProvider>();
    final products = catalog.products.where((product) => wishlist.contains(product.id)).toList();
    return SafeArea(
      child: products.isEmpty
          ? const EmptyState(title: 'No favourites yet', message: 'Tap the heart on a product to save it here.', icon: Icons.favorite_border)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Favourites', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                for (final product in products)
                  Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: product.imageUrl.isEmpty
                            ? const SizedBox(width: 48, height: 48, child: Icon(Icons.child_care))
                            : CachedNetworkImage(imageUrl: product.imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      title: Text(product.productName),
                      subtitle: Text(product.inStock ? 'In stock' : 'Out of stock'),
                      onTap: () => openProduct(context, product),
                      trailing: Wrap(
                        spacing: 0,
                        children: [
                          IconButton(
                            onPressed: product.inStock
                                ? () async {
                                    final message = await context.read<CartProvider>().add(product);
                                    if (context.mounted) showMessage(context, message ?? 'Moved to cart');
                                  }
                                : null,
                            icon: const Icon(Icons.add_shopping_cart),
                          ),
                          IconButton(onPressed: () => wishlist.toggle(product.id), icon: const Icon(Icons.favorite)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
