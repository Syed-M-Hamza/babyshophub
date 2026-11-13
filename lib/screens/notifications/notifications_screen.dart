import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/loading_widget.dart';
import '../orders/order_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    final service = NotificationService();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: uid == null
          ? const EmptyState(title: 'Sign in required', message: 'Notifications are saved to your account.')
          : StreamBuilder(
              stream: service.watch(uid),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) return const LoadingWidget();
                if (items.isEmpty) return const EmptyState(title: 'No notifications', message: 'Order updates and support replies will show up here.', icon: Icons.notifications_none);
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text('${item.body}\n${formatDate(item.createdAt)}'),
                        isThreeLine: true,
                        trailing: item.read ? null : const Icon(Icons.circle, size: 10),
                        onTap: () async {
                          if (!item.read) await service.markRead(item.id);
                          if (item.orderId != null && context.mounted) {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: item.orderId!)));
                          }
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
