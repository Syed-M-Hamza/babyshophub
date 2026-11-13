import 'package:flutter/material.dart';

import '../../data/showcase_catalog.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/clay_product_card.dart';

class ShopBrowse extends StatefulWidget {
  const ShopBrowse({super.key, required this.onOpenProduct, required this.onBack});

  final ValueChanged<Product> onOpenProduct;
  final VoidCallback onBack;

  @override
  State<ShopBrowse> createState() => _ShopBrowseState();
}

class _ShopBrowseState extends State<ShopBrowse> {
  static const _chips = ['All', 'Skincare', 'Toys', 'Clothes', 'Feeding', 'Nursery'];
  String _chip = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final items = showcaseProducts.where((product) {
      final matchesChip = _chip == 'All' || product.categoryId == _chip.toLowerCase();
      final matchesQuery = query.isEmpty || product.productName.toLowerCase().contains(query);
      return matchesChip && matchesQuery;
    }).toList();

    return ColoredBox(
      color: AppColors.softCream,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back, color: AppColors.navy)),
                  const Expanded(
                    child: Text('Explore', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB0A8A2)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final chip = _chips[index];
                  final selected = chip == _chip;
                  return ChoiceChip(
                    label: Text(chip),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFF6C7A8),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? const Color(0xFFF6C7A8) : const Color(0xFFE6E0DA)),
                    labelStyle: TextStyle(color: AppColors.navy, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                    onSelected: (_) => setState(() => _chip = chip),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No products in this category yet.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: productColumns(constraints.maxWidth),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 268,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final product = items[index];
                        return ClayProductCard(product: product, onOpen: () => widget.onOpenProduct(product));
                      },
                    );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
