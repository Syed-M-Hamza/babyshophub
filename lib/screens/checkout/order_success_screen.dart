import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../orders/order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 42, backgroundColor: AppColors.mintGreen, child: Icon(Icons.check, size: 42, color: AppColors.navy)),
              const SizedBox(height: 16),
              Text('Order placed', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your order is saved. You can follow its status from order history. This is not a live map.', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId)));
                },
                child: const Text('View order'),
              ),
              TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: const Text('Back home')),
            ],
          ),
        ),
      ),
    );
  }
}
