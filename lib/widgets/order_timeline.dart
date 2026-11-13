import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/formatters.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'delivered' || 'resolved' || 'paid' => AppColors.mintGreen,
      'cancelled' => AppColors.babyPink,
      'pending' || 'placed' => AppColors.babyBlue,
      _ => AppColors.pastelPeach,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(formatStatus(status), style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.status});

  final String status;

  static const steps = [
    'placed',
    'confirmed',
    'processing',
    'packed',
    'shipped',
    'out_for_delivery',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return const StatusBadge(status: 'cancelled');
    }
    final current = steps.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(i <= current ? Icons.check_circle : Icons.circle_outlined, color: i <= current ? AppColors.success : AppColors.muted, size: 20),
                  if (i != steps.length - 1) Container(width: 2, height: 22, color: i < current ? AppColors.success : AppColors.lightGrey),
                ],
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 1, bottom: 10),
                child: Text(formatStatus(steps[i]), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: i == current ? FontWeight.w800 : FontWeight.w600)),
              ),
            ],
          ),
      ],
    );
  }
}
