import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'category_card.dart';
import 'loading_widget.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap, this.width = 176});

  final Product product;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(product.categoryId);
    final wished = context.watch<WishlistProvider>().contains(product.id);
    final card = Material(
        color: style.background,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: AppColors.white,
                        child: product.imageUrl.isEmpty
                            ? Icon(style.icon, color: AppColors.navy, size: 36)
                            : CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => Icon(style.icon, color: AppColors.navy, size: 36),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Material(
                        color: AppColors.white,
                        shape: const CircleBorder(),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () async {
                            final message = await context.read<WishlistProvider>().toggle(product.id);
                            if (message != null && context.mounted) showMessage(context, message);
                          },
                          icon: Icon(wished ? Icons.favorite : Icons.favorite_border, color: wished ? AppColors.danger : AppColors.navy),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(product.brand, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.muted)),
                Text(product.productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(formatMoney(product.salePrice), style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    if (product.discount > 0) ...[
                      const SizedBox(width: 6),
                      Text(formatMoney(product.price), style: Theme.of(context).textTheme.labelSmall?.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.muted)),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.reviewCount == 0 ? 'New' : '${product.rating.toStringAsFixed(1)} · ${product.reviewCount}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: product.inStock
                        ? () async {
                            final message = await context.read<CartProvider>().add(product);
                            if (!context.mounted) return;
                            showMessage(context, message ?? 'Added to cart');
                          }
                        : null,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(38), backgroundColor: AppColors.navy),
                    child: Text(product.inStock ? 'Add to cart' : 'Out of stock'),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}

class ProductSection extends StatelessWidget {
  const ProductSection({super.key, required this.title, required this.products, required this.onOpen});

  final String title;
  final List<Product> products;
  final ValueChanged<Product> onOpen;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        SizedBox(
          height: 318,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product, onTap: () => onOpen(product));
            },
          ),
        ),
      ],
    );
  }
}
