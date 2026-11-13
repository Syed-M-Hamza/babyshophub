import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/address_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/local_address_book.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _store = FirestoreService();
  final Map<String, Address> _pending = {};

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.push<Address>(context, MaterialPageRoute(builder: (_) => AddressFormScreen(fullName: user?.fullName ?? '', phone: user?.phone ?? '')));
          if (saved != null) setState(() => _pending[saved.id] = saved);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListenableBuilder(
        listenable: LocalAddressBook.instance,
        builder: (context, _) {
          final local = [...LocalAddressBook.instance.items, ..._pending.values];
          if (user == null) {
            return _addressList(context, _merge(local, const []), null);
          }
          return StreamBuilder(
        stream: _store.watchAddresses(user.uid),
        builder: (context, snapshot) {
          final remote = snapshot.data ?? [];
          _pending.removeWhere((id, _) => remote.any((address) => address.id == id));
          final addresses = _merge([...local, ..._pending.values], remote);
          return _addressList(context, addresses, user);
        },
          );
        },
      ),
    );
  }

  List<Address> _merge(List<Address> local, List<Address> remote) {
    final byId = <String, Address>{};
    for (final address in remote) {
      byId[address.id] = address;
    }
    for (final address in local) {
      byId[address.id] = address;
    }
    final addresses = byId.values.toList();
    addresses.sort((a, b) {
      if (a.isDefault == b.isDefault) return a.label.compareTo(b.label);
      return a.isDefault ? -1 : 1;
    });
    return addresses;
  }

  Widget _addressList(BuildContext context, List<Address> addresses, AppUser? user) {
    if (addresses.isEmpty) {
      return const EmptyState(title: 'No addresses', message: 'Add a delivery address for checkout.', icon: Icons.location_on_outlined);
    }
    return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final address in addresses)
                Card(
                  child: ListTile(
                    title: Text('${address.label}${address.isDefault ? ' · Default' : ''}'),
                    subtitle: Text('${address.fullName}\n${address.summary}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final saved = await Navigator.push<Address>(context, MaterialPageRoute(builder: (_) => AddressFormScreen(existing: address, fullName: user?.fullName ?? address.fullName, phone: user?.phone ?? address.phone)));
                          if (saved != null && mounted) setState(() => _pending[saved.id] = saved);
                        } else if (value == 'default') {
                          final next = Address(id: address.id, label: address.label, fullName: address.fullName, phone: address.phone, line: address.line, city: address.city, postalCode: address.postalCode, isDefault: true);
                          LocalAddressBook.instance.save(next);
                          setState(() => _pending[next.id] = next);
                          if (user != null) {
                            Future<void>(() async {
                              try {
                                await _store.saveAddress(user.uid, next).timeout(const Duration(seconds: 3));
                              } catch (_) {}
                            });
                          }
                        } else if (value == 'delete') {
                          LocalAddressBook.instance.remove(address.id);
                          setState(() => _pending.remove(address.id));
                          if (user != null) {
                            Future<void>(() async {
                              try {
                                await _store.deleteAddress(user.uid, address.id).timeout(const Duration(seconds: 3));
                              } catch (_) {}
                            });
                          }
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'default', child: Text('Set default')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                ),
            ],
          );
  }
}

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.existing, required this.fullName, required this.phone});

  final Address? existing;
  final String fullName;
  final String phone;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _store = FirestoreService();
  late final TextEditingController _label = TextEditingController(text: widget.existing?.label ?? 'Home');
  late final TextEditingController _name = TextEditingController(text: widget.existing?.fullName ?? widget.fullName);
  late final TextEditingController _phone = TextEditingController(text: widget.existing?.phone ?? widget.phone);
  late final TextEditingController _line = TextEditingController(text: widget.existing?.line ?? '');
  late String _city = widget.existing?.city ?? '';
  late final TextEditingController _postal = TextEditingController(text: widget.existing?.postalCode ?? '');
  late bool _default = widget.existing?.isDefault ?? false;

  static const _cities = ['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Hyderabad', 'Peshawar', 'Quetta', 'Sialkot'];

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _phone.dispose();
    _line.dispose();
    _postal.dispose();
    super.dispose();
  }

  List<String> get _cityOptions {
    if (_city.isNotEmpty && !_cities.contains(_city)) return [_city, ..._cities];
    return _cities;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add address' : 'Edit address')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                BabyTextField(controller: _label, label: 'Label', validator: (value) => Validators.requiredField(value, label: 'Label')),
                const SizedBox(height: 12),
                BabyTextField(controller: _name, label: 'Full name', validator: Validators.fullName),
                const SizedBox(height: 12),
                BabyTextField(controller: _phone, label: 'Phone', keyboardType: TextInputType.phone, validator: Validators.phone),
                const SizedBox(height: 12),
                BabyTextField(controller: _line, label: 'Delivery address', validator: (value) => Validators.requiredField(value, label: 'Address')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _city.isEmpty ? null : _city,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'City', hintText: 'Choose a city'),
                  items: [for (final city in _cityOptions) DropdownMenuItem(value: city, child: Text(city))],
                  onChanged: (value) => setState(() => _city = value ?? ''),
                  validator: (value) => value == null || value.isEmpty ? 'Choose a city' : null,
                ),
                const SizedBox(height: 12),
                BabyTextField(controller: _postal, label: 'Postal code', validator: Validators.postalCode),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: _default, onChanged: (value) => setState(() => _default = value), title: const Text('Default address')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Save address',
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final user = context.read<AuthProvider>().user;
              final address = Address(
                id: widget.existing?.id.isNotEmpty == true ? widget.existing!.id : 'local-${DateTime.now().microsecondsSinceEpoch}',
                label: _label.text.trim(),
                fullName: _name.text.trim(),
                phone: _phone.text.trim(),
                line: _line.text.trim(),
                city: _city,
                postalCode: _postal.text.trim(),
                isDefault: _default,
              );
              LocalAddressBook.instance.save(address);
              Navigator.pop(context, address);
              final uid = user?.uid;
              if (uid != null) {
                Future<void>(() async {
                  try {
                    await _store.saveAddress(uid, address).timeout(const Duration(seconds: 3));
                  } catch (_) {}
                });
              }
            },
          ),
        ],
      ),
        ),
      ),
    );
  }
}
