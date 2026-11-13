import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_timeline.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.loading
          ? const LoadingWidget(label: 'Loading orders')
          : orders.orders.isEmpty
          ? const EmptyState(title: 'No orders yet', message: 'When you check out, your orders will appear here.', icon: Icons.receipt_long_outlined)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders.orders[index];
                return Card(
                  child: ListTile(
                    title: Text(order.orderNumber),
                    subtitle: Text('${formatDate(order.createdAt)}\n${formatMoney(order.totalAmount)} · ${formatStatus(order.paymentMethod)}'),
                    isThreeLine: true,
                    trailing: StatusBadge(status: order.orderStatus),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id))),
                  ),
                );
              },
            ),
    );
  }
}
