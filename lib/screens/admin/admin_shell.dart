import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/order_service.dart';
import '../../services/seed_service.dart';
import '../../services/support_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_timeline.dart';
import '../orders/order_detail_screen.dart';
import 'admin_category_form_screen.dart';
import 'admin_product_form_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;
  late final ProductProvider _products;

  @override
  void initState() {
    super.initState();
    _products = context.read<ProductProvider>()..retain();
  }

  @override
  void dispose() {
    _products.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [AdminDashboardScreen(), AdminProductsScreen(), AdminOrdersScreen(), AdminManageScreen()];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.tune), selectedIcon: Icon(Icons.tune), label: 'Manage'),
        ],
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: StreamBuilder(
        stream: FirestoreService().watchCustomers(),
        builder: (context, usersSnap) {
          return StreamBuilder(
            stream: OrderService().watchAll(),
            builder: (context, ordersSnap) {
              final users = usersSnap.data ?? [];
              final orders = ordersSnap.data ?? [];
              final pending = orders.where((order) => !['delivered', 'cancelled'].contains(order.orderStatus)).length;
              final delivered = orders.where((order) => order.orderStatus == 'delivered').length;
              final sales = orders.where((order) => order.orderStatus != 'cancelled').fold<int>(0, (sum, order) => sum + order.totalAmount);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Store overview', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _Stat('Products', '${catalog.products.length}', AppColors.babyPink),
                      _Stat('Customers', '${users.length}', AppColors.babyBlue),
                      _Stat('Orders', '${orders.length}', AppColors.mintGreen),
                      _Stat('Pending', '$pending', AppColors.pastelPeach),
                      _Stat('Delivered', '$delivered', AppColors.babyBlue),
                      _Stat('Sales', formatMoney(sales), AppColors.softCream),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Sales exclude cancelled orders. Figures update live from Firestore.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final message = await SeedService().seedCatalog();
                        if (context.mounted) showMessage(context, message);
                      } catch (error) {
                        if (context.mounted) showMessage(context, error.toString());
                      }
                    },
                    child: const Text('Seed sample catalog'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: () => context.read<AuthProvider>().setPreviewStore(true), child: const Text('View store')),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label), const SizedBox(height: 6), Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))]),
    );
  }
}

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products.where((product) {
      final text = _query.toLowerCase();
      return text.isEmpty || product.productName.toLowerCase().contains(text) || product.brand.toLowerCase().contains(text);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminProductFormScreen())), child: const Icon(Icons.add)),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: TextField(decoration: const InputDecoration(hintText: 'Search products'), onChanged: (value) => setState(() => _query = value))),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.productName),
                  subtitle: Text('${formatMoney(product.salePrice)} · stock ${product.stock}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await confirmAction(context, title: 'Delete product?', message: product.productName);
                      if (ok) await FirestoreService().deleteProduct(product.id);
                    },
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProductFormScreen(product: product))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _query = '';
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: StreamBuilder(
        stream: OrderService().watchAll(),
        builder: (context, snapshot) {
          final orders = (snapshot.data ?? []).where((order) {
            final text = _query.toLowerCase();
            final matchesText = text.isEmpty || order.orderNumber.toLowerCase().contains(text) || order.customerName.toLowerCase().contains(text);
            final matchesFilter = _filter == 'all' || order.orderStatus == _filter;
            return matchesText && matchesFilter;
          }).toList();
          return Column(
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: TextField(decoration: const InputDecoration(hintText: 'Search orders'), onChanged: (value) => setState(() => _query = value))),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['all', ...AppConstants.orderStatuses].map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(label: Text(formatStatus(status)), selected: _filter == status, onSelected: (_) => setState(() => _filter = status)),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? const EmptyState(title: 'No matching orders', message: 'Orders appear here after customers check out.')
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return ListTile(
                            title: Text('${order.orderNumber} · ${order.customerName}'),
                            subtitle: Text('${formatMoney(order.totalAmount)} · ${formatStatus(order.paymentStatus)}'),
                            trailing: StatusBadge(status: order.orderStatus),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminOrderManageScreen(orderId: order.id))),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminOrderManageScreen extends StatelessWidget {
  const AdminOrderManageScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: OrderService().watchAll(),
      builder: (context, snapshot) {
        final order = (snapshot.data ?? []).where((item) => item.id == orderId).firstOrNull;
        if (order == null) return const Scaffold(body: LoadingWidget());
        return Scaffold(
          appBar: AppBar(title: Text(order.orderNumber)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('${order.customerName}\n${order.phone}\n${order.address}, ${order.city} ${order.postalCode}'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id, admin: true))),
                child: const Text('View order details'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  var status = order.orderStatus;
                  var payment = order.paymentStatus;
                  await showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setSheet) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownMenu<String>(
                                  initialSelection: status,
                                  label: const Text('Order status'),
                                  dropdownMenuEntries: AppConstants.orderStatuses.map((item) => DropdownMenuEntry(value: item, label: formatStatus(item))).toList(),
                                  onSelected: (value) => setSheet(() => status = value ?? status),
                                ),
                                const SizedBox(height: 12),
                                DropdownMenu<String>(
                                  initialSelection: payment,
                                  label: const Text('Payment status'),
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(value: 'pending', label: 'Pending'),
                                    DropdownMenuEntry(value: 'paid', label: 'Paid'),
                                    DropdownMenuEntry(value: 'refunded', label: 'Refunded'),
                                  ],
                                  onSelected: (value) => setSheet(() => payment = value ?? payment),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () async {
                                    try {
                                      await OrderService().adminUpdate(order: order, orderStatus: status, paymentStatus: payment);
                                      if (context.mounted) Navigator.pop(context);
                                    } catch (error) {
                                      if (context.mounted) showMessage(context, error.toString());
                                    }
                                  },
                                  child: const Text('Save status'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: const Text('Update status'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminManageScreen extends StatelessWidget {
  const AdminManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage')),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.category_outlined), title: const Text('Categories'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoriesScreen()))),
          ListTile(leading: const Icon(Icons.people_outline), title: const Text('Customers'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
          ListTile(leading: const Icon(Icons.reviews_outlined), title: const Text('Reviews'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReviewsScreen()))),
          ListTile(leading: const Icon(Icons.support_agent_outlined), title: const Text('Support requests'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSupportScreen()))),
          ListTile(leading: const Icon(Icons.storefront_outlined), title: const Text('View store'), onTap: () => auth.setPreviewStore(true)),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () => auth.logout()),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Administrator access is granted only by creating an admins/{uid} document in the Firebase console. This app cannot promote accounts.'),
          ),
        ],
      ),
    );
  }
}

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    final products = context.watch<ProductProvider>().products;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCategoryFormScreen())), child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.categoryName),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (products.any((product) => product.categoryId == category.id)) {
                  showMessage(context, 'Move or delete products in this category first.');
                  return;
                }
                final ok = await confirmAction(context, title: 'Delete category?', message: category.categoryName);
                if (ok) await FirestoreService().deleteCategory(category.id);
              },
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCategoryFormScreen(category: category))),
          );
        },
      ),
    );
  }
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: StreamBuilder(
        stream: FirestoreService().watchCustomers(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? <AppUser>[];
          if (users.isEmpty) return const EmptyState(title: 'No customers', message: 'Registered accounts appear here. Passwords are never stored.');
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.fullName),
                subtitle: Text('${user.email}\n${user.phone}\n${user.uid}'),
                isThreeLine: true,
                trailing: Switch(
                  value: user.isActive,
                  onChanged: (value) => FirestoreService().setUserActive(user.uid, value),
                ),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: user.uid));
                  if (context.mounted) showMessage(context, 'Customer id copied');
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AdminReviewsScreen extends StatelessWidget {
  const AdminReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: StreamBuilder(
        stream: FirestoreService().watchAllReviews(),
        builder: (context, snapshot) {
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) return const EmptyState(title: 'No reviews', message: 'Customer reviews will appear here for moderation.');
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                title: Text('${review.userName} · ${review.rating}/5'),
                subtitle: Text(review.comment),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await confirmAction(context, title: 'Remove review?', message: 'This deletes the review and recalculates the product rating.');
                    if (ok) await FirestoreService().deleteReview(review);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: StreamBuilder(
        stream: SupportService().watchAll(),
        builder: (context, snapshot) {
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) return const EmptyState(title: 'No requests', message: 'Customer support tickets will appear here.');
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return ListTile(
                title: Text(ticket.subject),
                subtitle: Text('${ticket.customerName} · ${ticket.message}'),
                trailing: StatusBadge(status: ticket.status),
                onTap: () async {
                  final response = TextEditingController(text: ticket.adminResponse);
                  var status = ticket.status;
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
                        child: StatefulBuilder(
                          builder: (context, setSheet) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(ticket.subject, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(ticket.message),
                                const SizedBox(height: 12),
                                DropdownMenu<String>(
                                  initialSelection: status,
                                  dropdownMenuEntries: const [
                                    DropdownMenuEntry(value: 'pending', label: 'Pending'),
                                    DropdownMenuEntry(value: 'in_progress', label: 'In progress'),
                                    DropdownMenuEntry(value: 'resolved', label: 'Resolved'),
                                  ],
                                  onSelected: (value) => setSheet(() => status = value ?? status),
                                ),
                                const SizedBox(height: 12),
                                TextField(controller: response, maxLines: 4, decoration: const InputDecoration(labelText: 'Response')),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () async {
                                    await SupportService().respond(ticketId: ticket.id, status: status, response: response.text);
                                    if (context.mounted) Navigator.pop(context);
                                  },
                                  child: const Text('Send response'),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  );
                  response.dispose();
                },
              );
            },
          );
        },
      ),
    );
  }
}
