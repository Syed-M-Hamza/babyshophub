import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  final _store = FirestoreService();
  final _comment = TextEditingController();
  int _rating = 5;
  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Our store')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StreamBuilder(
            stream: _store.watchSeller(),
            builder: (context, snapshot) {
              final seller = snapshot.data;
              if (seller == null) {
                return const Text('BabyShopHub is a single-store boutique. An administrator can publish the store profile from the sample catalog.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seller.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  Text(seller.city),
                  Text(seller.email),
                  const SizedBox(height: 8),
                  Text(seller.description),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: _store.watchSellerFeedback(),
            builder: (context, snapshot) {
              final feedback = snapshot.data ?? [];
              final average = feedback.isEmpty ? 0 : feedback.fold<int>(0, (sum, item) => sum + item.rating) / feedback.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feedback.isEmpty ? 'No store ratings yet' : 'Store rating ${average.toStringAsFixed(1)} from ${feedback.length}'),
                  for (final item in feedback.take(8))
                    ListTile(contentPadding: EdgeInsets.zero, title: Text(item.userName), subtitle: Text(item.comment), trailing: Text('${item.rating}/5')),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(onPressed: () => setState(() => _rating = star), icon: Icon(star <= _rating ? Icons.star : Icons.star_border));
            }),
          ),
          TextField(controller: _comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Store feedback')),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Submit feedback',
            loading: _saving,
            onPressed: user == null
                ? null
                : () async {
                    if (_comment.text.trim().length < 3) {
                      showMessage(context, 'Write a short comment first.');
                      return;
                    }
                    setState(() => _saving = true);
                    try {
                      await _store.saveSellerFeedback(uid: user.uid, userName: user.fullName, rating: _rating, comment: _comment.text);
                      _comment.clear();
                      if (context.mounted) showMessage(context, 'Thanks for the feedback');
                    } catch (error) {
                      if (context.mounted) showMessage(context, error.toString());
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
