import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/showcase_catalog.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, this.productId = '', this.product});

  final String productId;
  final Product? product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

Product? _fromShowcase(String id) {
  for (final product in showcaseProducts) {
    if (product.id == id) return product;
  }
  return null;
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _store = FirestoreService();
  final _comment = TextEditingController();
  int _quantity = 1;
  int _rating = 5;
  bool _savingReview = false;
  bool _reviewsOpen = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product ?? context.watch<ProductProvider>().find(widget.productId) ?? _fromShowcase(widget.productId);
    if (product == null) {
      return const Scaffold(body: EmptyState(title: 'Product unavailable', message: 'This product may have been removed.'));
    }
    final wished = context.watch<WishlistProvider>().contains(product.id);
    final stars = product.rating.round().clamp(0, 5);

    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        backgroundColor: AppColors.softCream,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
        title: const Text('Product details'),
        actions: [
          IconButton(
            onPressed: () => context.read<WishlistProvider>().toggle(product.id),
            icon: Icon(wished ? Icons.favorite : Icons.favorite_border, color: wished ? const Color(0xFFE07A7A) : AppColors.navy),
          ),
        ],
      ),
      body: ShopFrame(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(color: Color(product.cardColor), borderRadius: BorderRadius.circular(28)),
            padding: const EdgeInsets.all(18),
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const Icon(Icons.child_care, size: 96, color: AppColors.navy),
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF1E6), borderRadius: BorderRadius.circular(20)),
              child: Text(product.categoryId, style: const TextStyle(color: Color(0xFFE08A5A), fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.productName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy, height: 1.15)),
          const SizedBox(height: 6),
          Text(product.displayPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFFE08A5A))),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < 5; index++) Icon(index < stars ? Icons.star : Icons.star_border, color: const Color(0xFFF0B429), size: 20),
              const SizedBox(width: 8),
              Text('${product.reviewCount} reviews', style: const TextStyle(color: Color(0xFF8A8490))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('About this product', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          const SizedBox(height: 6),
          Text(product.description, style: const TextStyle(height: 1.45, color: AppColors.navy)),
          const SizedBox(height: 18),
          Row(
            children: [
              _QtyBox(icon: Icons.remove, onTap: _quantity > 1 ? () => setState(() => _quantity--) : null),
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              _QtyBox(icon: Icons.add, onTap: _quantity < product.stock ? () => setState(() => _quantity++) : null),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  await context.read<CartProvider>().add(product, quantity: _quantity);
                  if (!context.mounted) return;
                  showMessage(context, 'Saved for your next order');
                },
                child: const Text('Repeat order', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reviews', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
            trailing: Icon(_reviewsOpen ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _reviewsOpen = !_reviewsOpen),
          ),
          if (_reviewsOpen) _reviewBox(product),
          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3E8B62), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () async {
                await context.read<CartProvider>().add(product, quantity: _quantity);
                if (!context.mounted) return;
                showMessage(context, 'Added to cart');
              },
              child: const Text('Add to cart', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _reviewBox(Product product) {
    return StreamBuilder(
      stream: _store.watchProductReviews(product.id),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reviews.isEmpty) const Text('No reviews yet.'),
            for (final review in reviews) ListTile(contentPadding: EdgeInsets.zero, title: Text(review.userName), subtitle: Text(review.comment), trailing: Text('${review.rating}/5')),
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(onPressed: () => setState(() => _rating = star), icon: Icon(star <= _rating ? Icons.star : Icons.star_border, color: const Color(0xFFF0B429)));
              }),
            ),
            TextField(controller: _comment, decoration: const InputDecoration(labelText: 'Write a review')),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _savingReview
                    ? null
                    : () async {
                        final user = context.read<AuthProvider>().user;
                        if (user == null) {
                          showMessage(context, 'Reviews need a signed-in shopper.');
                          return;
                        }
                        if (_comment.text.trim().length < 3) return;
                        setState(() => _savingReview = true);
                        try {
                          await _store.addReview(product: product, uid: user.uid, userName: user.fullName, rating: _rating, comment: _comment.text);
                          _comment.clear();
                          if (context.mounted) showMessage(context, 'Review saved');
                        } catch (error) {
                          if (context.mounted) showMessage(context, error.toString());
                        } finally {
                          if (mounted) setState(() => _savingReview = false);
                        }
                      },
                child: const Text('Submit'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QtyBox extends StatelessWidget {
  const _QtyBox({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE6E0DA)), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
