import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/support_service.dart';
import '../../utils/app_constants.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/order_timeline.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final service = SupportService();
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: user == null ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New request'),
      ),
      body: user == null
          ? const EmptyState(title: 'Sign in required', message: 'Support requests are saved to your account.')
          : StreamBuilder(
              stream: service.watchForUser(user.uid),
              builder: (context, snapshot) {
                final tickets = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) return const LoadingWidget();
                if (tickets.isEmpty) {
                  return const EmptyState(title: 'No requests yet', message: 'Contact support, send feedback or report a problem.', icon: Icons.support_agent_outlined);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Card(
                      child: ListTile(
                        title: Text(ticket.subject),
                        subtitle: Text('${ticket.category} · ${formatDate(ticket.createdAt)}'),
                        trailing: StatusBadge(status: ticket.status),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SupportDetailScreen(ticketId: ticket.id))),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class SupportFormScreen extends StatefulWidget {
  const SupportFormScreen({super.key});

  @override
  State<SupportFormScreen> createState() => _SupportFormScreenState();
}

class _SupportFormScreenState extends State<SupportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SupportService();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _category = AppConstants.supportCategories.first;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: user.fullName);
    _email = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Use this form for feedback, a problem report, or a question about an order.'),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                BabyTextField(controller: _name, label: 'Name', validator: Validators.fullName),
                const SizedBox(height: 12),
                BabyTextField(controller: _email, label: 'Email', validator: Validators.email),
                const SizedBox(height: 12),
                DropdownMenu<String>(
                  initialSelection: _category,
                  label: const Text('Issue category'),
                  dropdownMenuEntries: AppConstants.supportCategories.map((item) => DropdownMenuEntry(value: item, label: item)).toList(),
                  onSelected: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 12),
                BabyTextField(controller: _subject, label: 'Subject', validator: (value) => Validators.requiredField(value, label: 'Subject')),
                const SizedBox(height: 12),
                BabyTextField(controller: _message, label: 'Message', maxLines: 5, validator: Validators.message),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'Submit',
            loading: _saving,
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              final user = context.read<AuthProvider>().user;
              if (user == null) return;
              setState(() => _saving = true);
              try {
                await _service.submit(uid: user.uid, customerName: _name.text, email: _email.text, category: _category, subject: _subject.text, message: _message.text);
                if (context.mounted) {
                  showMessage(context, 'Request sent');
                  Navigator.pop(context);
                }
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

class SupportDetailScreen extends StatelessWidget {
  const SupportDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request')),
      body: StreamBuilder(
        stream: SupportService().watchForUser(context.watch<AuthProvider>().user?.uid ?? ''),
        builder: (context, snapshot) {
          final ticket = (snapshot.data ?? []).where((item) => item.id == ticketId).firstOrNull;
          if (ticket == null) return const LoadingWidget();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(ticket.subject, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              StatusBadge(status: ticket.status),
              const SizedBox(height: 12),
              Text('${ticket.customerName} · ${ticket.email}'),
              Text(ticket.category),
              const SizedBox(height: 12),
              Text(ticket.message),
              const SizedBox(height: 16),
              Text('Response', style: Theme.of(context).textTheme.titleLarge),
              Text(ticket.adminResponse.isEmpty ? 'Waiting for a reply.' : ticket.adminResponse),
            ],
          );
        },
      ),
    );
  }
}
