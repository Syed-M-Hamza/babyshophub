import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_colors.dart';
import 'loading_widget.dart';

class ClayProductCard extends StatelessWidget {
  const ClayProductCard({super.key, required this.product, required this.onOpen, this.compact = false});

  final Product product;
  final VoidCallback onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final wished = context.watch<WishlistProvider>().contains(product.id);
    return SizedBox(
      width: compact ? 188 : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Color(0x1424244F), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: compact ? 112 : 124,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Color(product.cardColor), borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.all(8),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(Icons.child_care, size: 42, color: AppColors.navy),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.read<WishlistProvider>().toggle(product.id),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(wished ? Icons.favorite : Icons.favorite_border, size: 18, color: wished ? const Color(0xFFE07A7A) : AppColors.navy),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(product.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.navy)),
                const SizedBox(height: 2),
                Text(_label(product.categoryId), style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(product.displayPrice, style: const TextStyle(color: AppColors.softOrange, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3E8B62),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final message = await context.read<CartProvider>().add(product);
                      if (!context.mounted) return;
                      showMessage(context, message ?? 'Added to cart');
                    },
                    child: const Text('Add to cart', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  String _label(String id) {
    return switch (id) {
      'skincare' => 'Skincare',
      'toys' => 'Toys',
      'clothes' => 'Clothes',
      'feeding' => 'Feeding',
      'nursery' => 'Nursery',
      _ => 'Baby',
    };
  }
}
