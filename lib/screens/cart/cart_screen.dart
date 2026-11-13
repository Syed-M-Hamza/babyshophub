import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/pricing.dart';
import '../../widgets/category_card.dart';
import '../../widgets/loading_widget.dart';
import '../checkout/checkout_screen.dart';
import '../products/product_detail_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final catalog = context.watch<ProductProvider>();
    final lines = cart.items.map((item) => (item: item, product: catalog.find(item.productId))).toList();
    final subtotal = lines.fold<int>(0, (sum, line) {
      final product = line.product;
      if (product == null) return sum;
      return sum + Pricing.lineTotal(product.price, product.discount, line.item.quantity);
    });
    final delivery = Pricing.deliveryCharge(subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.loading && cart.items.isEmpty
          ? const LoadingWidget(label: 'Loading cart')
          : lines.isEmpty
          ? const EmptyState(title: 'Your cart is empty', message: 'Add a product from the home or explore tab.', icon: Icons.shopping_bag_outlined)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final line in lines)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: line.product == null
                          ? ListTile(
                              title: const Text('Unavailable product'),
                              trailing: IconButton(onPressed: () => cart.remove(line.item.productId), icon: const Icon(Icons.delete_outline)),
                            )
                          : Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    color: categoryStyle(line.product!.categoryId).background,
                                    child: line.product!.imageUrl.isEmpty
                                        ? const Icon(Icons.child_care)
                                        : CachedNetworkImage(imageUrl: line.product!.imageUrl, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: line.product))),
                                        child: Text(line.product!.productName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                      Text(formatMoney(line.product!.salePrice)),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => cart.setQuantity(line.product!, line.item.quantity - 1),
                                            icon: const Icon(Icons.remove_circle_outline),
                                          ),
                                          Text('${line.item.quantity}'),
                                          IconButton(
                                            onPressed: () async {
                                              final message = await cart.setQuantity(line.product!, line.item.quantity + 1);
                                              if (message != null && context.mounted) showMessage(context, message);
                                            },
                                            icon: const Icon(Icons.add_circle_outline),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(onPressed: () => cart.remove(line.item.productId), icon: const Icon(Icons.delete_outline)),
                              ],
                            ),
                    ),
                  ),
                const SizedBox(height: 12),
                _TotalRow(label: 'Subtotal', value: formatMoney(subtotal)),
                _TotalRow(label: 'Delivery', value: delivery == 0 ? 'Free' : formatMoney(delivery)),
                _TotalRow(label: 'Total', value: formatMoney(subtotal + delivery), strong: true),
                const SizedBox(height: 8),
                Text(
                  subtotal >= 2000 ? 'You have free delivery.' : 'Free delivery on orders of Rs 2,000 or more.',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: lines.any((line) => line.product == null || !line.product!.inStock || line.item.quantity > line.product!.stock)
                      ? () => showMessage(context, 'Remove unavailable items or reduce quantities before checkout.')
                      : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                  child: const Text('Checkout'),
                ),
              ],
            ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: strong ? FontWeight.w800 : FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]),
    );
  }
}
