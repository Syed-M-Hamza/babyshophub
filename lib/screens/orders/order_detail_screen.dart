import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_timeline.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, required this.orderId, this.admin = false});

  final String orderId;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: LoadingWidget(label: 'Loading order'));
        if (!snapshot.data!.exists) return const Scaffold(body: EmptyState(title: 'Order not found', message: 'This order is no longer available.'));
        final order = ShopOrder.fromDoc(snapshot.data!.id, snapshot.data!.data() ?? {});
        return Scaffold(
          appBar: AppBar(title: Text(order.orderNumber)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(formatDate(order.createdAt)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [StatusBadge(status: order.orderStatus), StatusBadge(status: order.paymentStatus)]),
              const SizedBox(height: 16),
              Text('Tracking', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text('Status updates come from the store. This timeline is not GPS tracking.'),
              const SizedBox(height: 12),
              OrderTimeline(status: order.orderStatus),
              const SizedBox(height: 16),
              Text('Delivery', style: Theme.of(context).textTheme.titleLarge),
              Text('${order.customerName}\n${order.phone}\n${order.address}, ${order.city} ${order.postalCode}'),
              const SizedBox(height: 16),
              Text('Items', style: Theme.of(context).textTheme.titleLarge),
              for (final line in order.products)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: line.image.isEmpty
                      ? const Icon(Icons.child_care)
                      : ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: line.image, width: 48, height: 48, fit: BoxFit.cover)),
                  title: Text(line.productName),
                  subtitle: Text('${formatMoney(line.unitPrice)} × ${line.quantity}'),
                  trailing: Text(formatMoney(line.lineTotal)),
                ),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Subtotal'), trailing: Text(formatMoney(order.subtotal))),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Delivery'), trailing: Text(formatMoney(order.deliveryCharges))),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Total'), trailing: Text(formatMoney(order.totalAmount))),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Payment'), trailing: Text(formatStatus(order.paymentMethod))),
              if (!admin && order.canCustomerCancel) ...[
                const SizedBox(height: 12),
                CustomButton(
                  label: 'Cancel order',
                  outlined: true,
                  onPressed: () async {
                    final ok = await confirmAction(context, title: 'Cancel order?', message: 'You can cancel while the order is placed or confirmed.');
                    if (!ok || !context.mounted) return;
                    try {
                      await context.read<OrderProvider>().service.cancelOrder(order);
                      if (context.mounted) showMessage(context, 'Order cancelled');
                    } catch (error) {
                      if (context.mounted) showMessage(context, error.toString());
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
