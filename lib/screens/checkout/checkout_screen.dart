import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/local_address_book.dart';
import '../../theme/app_colors.dart';
import '../../utils/formatters.dart';
import '../../utils/pricing.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../profile/address_form_screen.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _store = FirestoreService();
  String? _addressId;
  Address? _savedAddress;
  String _payment = 'cod';
  bool _placing = false;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cart = context.watch<CartProvider>();
    final catalog = context.watch<ProductProvider>();
    if (user == null) return const Scaffold(body: EmptyState(title: 'Sign in required', message: 'Log in before checkout.'));

    final priced = cart.items.where((item) => catalog.find(item.productId) != null).toList();
    final subtotal = priced.fold<int>(0, (sum, item) {
      final product = catalog.find(item.productId)!;
      return sum + Pricing.lineTotal(product.price, product.discount, item.quantity);
    });
    final delivery = Pricing.deliveryCharge(subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListenableBuilder(
        listenable: LocalAddressBook.instance,
        builder: (context, _) => StreamBuilder(
        stream: _store.watchAddresses(user.uid),
        builder: (context, snapshot) {
          final remote = snapshot.data ?? [];
          final local = <Address>[
            ?_savedAddress,
            ...LocalAddressBook.instance.items,
          ];
          final byId = <String, Address>{for (final address in remote) address.id: address};
          for (final address in local) {
            byId[address.id] = address;
          }
          final addresses = byId.values.toList();
          final selected = addresses.cast<Address?>().firstWhere(
            (address) => address!.id == _addressId,
            orElse: () => addresses.where((address) => address.isDefault).firstOrNull ?? (addresses.isEmpty ? null : addresses.first),
          );
          _addressId ??= selected?.id;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Delivery address', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (addresses.isEmpty)
                OutlinedButton(onPressed: () => _addAddress(user.fullName, user.phone), child: const Text('Add an address'))
              else
                for (final address in addresses)
                  Card(
                    color: address.id == _addressId ? AppColors.babyBlue : AppColors.white,
                    child: ListTile(
                      title: Text(address.label),
                      subtitle: Text('${address.fullName}\n${address.summary}\n${address.phone}'),
                      isThreeLine: true,
                      onTap: () => setState(() => _addressId = address.id),
                    ),
                  ),
              TextButton(onPressed: () => _addAddress(user.fullName, user.phone), child: const Text('Add another address')),
              const SizedBox(height: 8),
              Text('Payment', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _PayCard(
                title: 'Cash on delivery',
                body: 'Pay when the order arrives. No card details are collected.',
                selected: _payment == 'cod',
                onTap: () => setState(() => _payment = 'cod'),
              ),
              _PayCard(
                title: 'Dummy online payment',
                body: 'Academic demo only. This marks the order paid without a real payment or card form.',
                selected: _payment == 'dummy_online',
                onTap: () => setState(() => _payment = 'dummy_online'),
              ),
              const SizedBox(height: 12),
              Text('Order summary', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final item in priced)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(catalog.find(item.productId)!.productName),
                  subtitle: Text('Qty ${item.quantity}'),
                  trailing: Text(formatMoney(Pricing.lineTotal(catalog.find(item.productId)!.price, catalog.find(item.productId)!.discount, item.quantity))),
                ),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Delivery'), trailing: Text(delivery == 0 ? 'Free' : formatMoney(delivery))),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Total'), trailing: Text(formatMoney(subtotal + delivery))),
              const SizedBox(height: 12),
              CustomButton(
                label: _payment == 'cod' ? 'Place order' : 'Confirm demo payment',
                loading: _placing,
                onPressed: selected == null || priced.isEmpty
                    ? null
                    : () => _place(selected, user.fullName, user.phone),
              ),
            ],
          ),
            ),
          );
        },
      ),
      ),
    );
  }

  Future<void> _addAddress(String name, String phone) async {
    final saved = await Navigator.push<Address>(context, MaterialPageRoute(builder: (_) => AddressFormScreen(fullName: name, phone: phone)));
    if (saved != null && mounted) {
      setState(() {
        _savedAddress = saved;
        _addressId = saved.id;
      });
    }
  }

  Future<void> _place(Address address, String name, String phone) async {
    if (_placing) return;
    setState(() => _placing = true);
    final user = context.read<AuthProvider>().user!;
    final cart = context.read<CartProvider>();
    try {
      final orderId = await context.read<OrderProvider>().service.placeOrder(
        uid: user.uid,
        customerName: address.fullName.isEmpty ? name : address.fullName,
        phone: address.phone.isEmpty ? phone : address.phone,
        address: address,
        paymentMethod: _payment,
        items: cart.items,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId)));
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard({required this.title, required this.body, required this.selected, required this.onTap});

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? AppColors.babyPink : AppColors.white,
      child: ListTile(
        onTap: onTap,
        leading: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off),
        title: Text(title),
        subtitle: Text(body),
      ),
    );
  }
}
