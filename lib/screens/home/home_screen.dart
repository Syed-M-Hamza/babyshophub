import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import '../../data/showcase_catalog.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_cartoons.dart';
import '../../widgets/clay_product_card.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import 'collection_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenExplore,
    required this.onOpenProfile,
    required this.onOpenProduct,
    required this.onOpenCategory,
  });

  final VoidCallback onOpenExplore;
  final VoidCallback onOpenProfile;
  final ValueChanged<Product> onOpenProduct;
  final ValueChanged<Category> onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    return ColoredBox(
      color: AppColors.softCream,
      child: SafeArea(
        child: ShopFrame(
        child: ListView(
          padding: EdgeInsets.fromLTRB(wide ? 32 : 20, 12, wide ? 32 : 20, wide ? 40 : 120),
          children: [
            Row(
              children: [
                if (!wide)
                  IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu_rounded, color: AppColors.navy),
                  ),
                const Expanded(
                  child: Text('BabyShopHub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy)),
                ),
                IconButton(
                  tooltip: 'Cart',
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.navy),
                ),
                _LoginButton(onOpenProfile: onOpenProfile),
              ],
            ),
            const SizedBox(height: 14),
            _SearchField(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopSearchScreen()))),
            const SizedBox(height: 20),
            const _BabyPortrait(),
            const SizedBox(height: 16),
            const _NapkinBanner(),
            const SizedBox(height: 28),
            const Text('Shop by category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const SizedBox(height: 12),
            _CartoonCategories(
              onOpen: (category) {
                onOpenCategory(category);
                final products = showcaseProducts.where((product) => product.categoryId == category.id).toList();
                _openCollection(context, category.categoryName, products);
              },
            ),
            const SizedBox(height: 22),
            for (final category in showcaseCategories.where((item) => const {'skincare', 'toys', 'clothes', 'feeding'}.contains(item.id))) ...[
              _SectionTitle(
                title: category.categoryName,
                onSeeAll: () {
                  onOpenCategory(category);
                  _openCollection(context, category.categoryName, showcaseProducts.where((product) => product.categoryId == category.id).toList());
                },
              ),
              const SizedBox(height: 12),
              _ProductStrip(
                products: showcaseProducts.where((product) => product.categoryId == category.id).toList(),
                onOpen: onOpenProduct,
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onOpenProfile});

  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().user?.email ?? '';
    if (email.isNotEmpty) {
      return IconButton(onPressed: onOpenProfile, icon: const Icon(Icons.verified_user_outlined, color: AppColors.navy));
    }
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFF4B183),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (loginContext) => LoginScreen(
              onForgot: () {
                Navigator.of(loginContext).push(
                  MaterialPageRoute(builder: (_) => ForgotPasswordScreen(onLogin: () => Navigator.of(loginContext).pop())),
                );
              },
            ),
          ),
        );
      },
      child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _CartoonCategories extends StatelessWidget {
  const _CartoonCategories({required this.onOpen});

  final ValueChanged<Category> onOpen;

  @override
  Widget build(BuildContext context) {
    const buddies = [
      (ClayBuddy.skincare, 'skincare'),
      (ClayBuddy.toys, 'toys'),
      (ClayBuddy.clothes, 'clothes'),
      (ClayBuddy.feeding, 'feeding'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final tiles = [
          for (final buddy in buddies)
            ClayCartoonButton(
              buddy: buddy.$1,
              label: showcaseCategories.firstWhere((category) => category.id == buddy.$2).categoryName,
              onTap: () => onOpen(showcaseCategories.firstWhere((category) => category.id == buddy.$2)),
            ),
        ];
        if (constraints.maxWidth < 560) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.86,
            children: tiles,
          );
        }
        return Row(
          children: [
            for (var i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: tiles[i]),
            ],
          ],
        );
      },
    );
  }
}

class _ProductStrip extends StatelessWidget {
  const _ProductStrip({required this.products, required this.onOpen});

  final List<Product> products;
  final ValueChanged<Product> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 268,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ClayProductCard(product: product, onOpen: () => onOpen(product));
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: 'Search Products',
        prefixIcon: const Icon(Icons.search, color: Color(0xFFB0A8A2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
      ),
    );
  }
}

void _openCollection(BuildContext context, String title, List<Product> products) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => CollectionScreen(title: title, products: products)));
}

class _BabyPortrait extends StatelessWidget {
  const _BabyPortrait();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.asset('lib/babyimg.jpg', height: 230, width: double.infinity, fit: BoxFit.cover),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xCC24254F)],
              ),
            ),
            child: const Text('Little smiles, soft days', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _NapkinBanner extends StatelessWidget {
  const _NapkinBanner();

  @override
  Widget build(BuildContext context) {
    return Clay(
      color: const Color(0xFFF8D7D2),
      padding: const EdgeInsets.all(16),
      radius: 28,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset('lib/napkinpic.png', width: 112, height: 112, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Baby Napkin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.navy, height: 1.1)),
                SizedBox(height: 8),
                Text('Get up to 40% off', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Soft essentials for little ones', style: TextStyle(color: Color(0xFF6E6880), fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
        const Spacer(),
        TextButton(onPressed: onSeeAll, child: const Text('See all', style: TextStyle(color: Color(0xFF8E90A8)))),
      ],
    );
  }
}

