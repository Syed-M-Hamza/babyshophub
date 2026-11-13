import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../services/push_messaging.dart';
import '../../theme/app_colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/curve_marquee.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../products/product_detail_screen.dart';
import '../seller/seller_screen.dart';
import '../support/support_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../admin/admin_shell.dart';
import '../profile/profile_screen.dart';

void openProduct(BuildContext context, Product product) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
}

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;
  late final ProductProvider _products;
  late final CartProvider _cart;
  late final WishlistProvider _wishlist;
  late final OrderProvider _orders;
  String? _boundUid;

  @override
  void initState() {
    super.initState();
    _products = context.read<ProductProvider>()..retain();
    _cart = context.read<CartProvider>();
    _wishlist = context.read<WishlistProvider>();
    _orders = context.read<OrderProvider>();
    _bind(context.read<AuthProvider>().user?.uid);
  }

  void _bind(String? uid) {
    if (uid == null || uid == _boundUid) return;
    _boundUid = uid;
    _cart.retain(uid);
    _wishlist.retain(uid);
    _orders.retain(uid);
    PushMessaging.start(uid);
  }

  @override
  void dispose() {
    _products.release();
    if (_boundUid != null) {
      _cart.release();
      _wishlist.release();
      _orders.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _bind(auth.user?.uid);
    final favouriteCount = context.watch<WishlistProvider>().ids.length;
    final pages = [
      HomeScreen(
        onOpenExplore: () => setState(() => _index = 1),
        onOpenProfile: () => setState(() => _index = 3),
        onOpenProduct: (product) => openProduct(context, product),
        onOpenCategory: (category) {
          context.read<ProductProvider>().applyFilters(categoryId: category.id, minPrice: null, maxPrice: null);
        },
      ),
      ShopBrowse(
        onOpenProduct: (product) => openProduct(context, product),
        onBack: () => setState(() => _index = 0),
      ),
      const WishlistScreen(),
      const ProfileScreen(),
    ];

    final wide = isWideScreen(context);
    final destinations = [
      const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
      const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
      NavigationDestination(
        icon: Badge(isLabelVisible: favouriteCount > 0, label: Text('$favouriteCount'), child: const Icon(Icons.favorite_outline)),
        selectedIcon: const Icon(Icons.favorite),
        label: 'Favourite',
      ),
      const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
    return ShellTab(
      select: (value) => setState(() => _index = value),
      child: Scaffold(
      backgroundColor: AppColors.softCream,
      drawer: wide ? null : Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(backgroundColor: AppColors.pastelPeach, child: Icon(Icons.child_care, color: AppColors.navy)),
                    const SizedBox(height: 12),
                    Text(auth.user?.fullName ?? 'BabyShopHub', style: Theme.of(context).textTheme.titleLarge),
                    Text(auth.user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => _go(0)),
              ListTile(leading: const Icon(Icons.explore_outlined), title: const Text('Explore'), onTap: () => _go(1)),
              ListTile(leading: const Icon(Icons.favorite_outline), title: const Text('Favourites'), onTap: () => _go(2)),
              ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), onTap: () => _go(3)),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text('Cart'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('My orders'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent_outlined),
                title: const Text('Support'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Our store'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerScreen()));
                },
              ),
              if (auth.isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Admin dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell()));
                  },
                ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              backgroundColor: const Color(0xFFFFF8F4),
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: const IconThemeData(color: Color(0xFFE08A5A)),
              unselectedIconTheme: const IconThemeData(color: Color(0xFF8A8490)),
              destinations: [
                for (final destination in destinations)
                  NavigationRailDestination(icon: destination.icon, selectedIcon: destination.selectedIcon, label: Text(destination.label)),
              ],
            ),
          Expanded(
            child: Column(
              children: [
                if (auth.previewStore)
                  MaterialBanner(
                    content: const Text('You are previewing the store as an administrator.'),
                    actions: [TextButton(onPressed: () => auth.setPreviewStore(false), child: const Text('Back to admin'))],
                  ),
                const CurveMarquee(),
                Expanded(child: IndexedStack(index: _index, children: pages)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: wide ? null : NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFFFFF8F4),
          indicatorColor: const Color(0xFFF8D2C4),
          height: 72,
          elevation: 8,
          shadowColor: const Color(0x33000000),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? const Color(0xFFE08A5A) : const Color(0xFF8A8490));
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? const Color(0xFFE08A5A) : const Color(0xFF8A8490));
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: destinations,
        ),
      ),
      floatingActionButton: null,
      ),
    );
  }

  void _go(int index) {
    setState(() => _index = index);
    Navigator.pop(context);
  }
}

class ShellTab extends InheritedWidget {
  const ShellTab({super.key, required this.select, required super.child});

  final ValueChanged<int> select;

  static ShellTab? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellTab>();

  @override
  bool updateShouldNotify(ShellTab oldWidget) => false;
}
