import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.product?.productName ?? '');
  late final TextEditingController _brand = TextEditingController(text: widget.product?.brand ?? '');
  late final TextEditingController _description = TextEditingController(text: widget.product?.description ?? '');
  late final TextEditingController _price = TextEditingController(text: widget.product?.price.toString() ?? '');
  late final TextEditingController _discount = TextEditingController(text: widget.product?.discount.toString() ?? '0');
  late final TextEditingController _stock = TextEditingController(text: widget.product?.stock.toString() ?? '');
  late final TextEditingController _popularity = TextEditingController(text: widget.product?.popularity.toString() ?? '0');
  late final TextEditingController _imageUrl = TextEditingController();
  late final List<String> _images = [...?widget.product?.images];
  late String? _categoryId = widget.product?.categoryId;
  late bool _available = widget.product?.isAvailable ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _description.dispose();
    _price.dispose();
    _discount.dispose();
    _stock.dispose();
    _popularity.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    return Scaffold(
      appBar: AppBar(title: Text(widget.product == null ? 'Add product' : 'Edit product')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                BabyTextField(controller: _name, label: 'Product name', validator: (value) => Validators.requiredField(value, label: 'Name')),
                const SizedBox(height: 12),
                BabyTextField(controller: _brand, label: 'Brand', validator: (value) => Validators.requiredField(value, label: 'Brand')),
                const SizedBox(height: 12),
                BabyTextField(controller: _description, label: 'Description', maxLines: 4, validator: (value) => Validators.requiredField(value, label: 'Description')),
                const SizedBox(height: 12),
                DropdownMenu<String>(
                  initialSelection: _categoryId,
                  label: const Text('Category'),
                  dropdownMenuEntries: categories.map((category) => DropdownMenuEntry(value: category.id, label: category.categoryName)).toList(),
                  onSelected: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: 12),
                BabyTextField(controller: _price, label: 'Price (Rs)', keyboardType: TextInputType.number, validator: _positive),
                const SizedBox(height: 12),
                BabyTextField(controller: _discount, label: 'Discount percent', keyboardType: TextInputType.number, validator: _discountValidator),
                const SizedBox(height: 12),
                BabyTextField(controller: _stock, label: 'Stock', keyboardType: TextInputType.number, validator: _stockValidator),
                const SizedBox(height: 12),
                BabyTextField(controller: _popularity, label: 'Popularity', keyboardType: TextInputType.number, validator: _stockValidator),
                SwitchListTile(contentPadding: EdgeInsets.zero, value: _available, onChanged: (value) => setState(() => _available = value), title: const Text('Available')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final image in _images)
            ListTile(
              title: Text(image, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(onPressed: () => setState(() => _images.remove(image)), icon: const Icon(Icons.close)),
            ),
          BabyTextField(controller: _imageUrl, label: 'Image URL'),
          TextButton(onPressed: () {
            final url = _imageUrl.text.trim();
            if (url.isEmpty) return;
            setState(() {
              _images.add(url);
              _imageUrl.clear();
            });
          }, child: const Text('Add image URL')),
          OutlinedButton(onPressed: _upload, child: const Text('Upload image')),
          const SizedBox(height: 12),
          CustomButton(label: 'Save product', loading: _saving, onPressed: categories.isEmpty ? null : _save),
        ],
      ),
    );
  }

  String? _positive(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed <= 0) return 'Enter a price above 0';
    return null;
  }

  String? _discountValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0 || parsed > 90) return 'Use 0 to 90';
    return null;
  }

  String? _stockValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return 'Enter 0 or more';
    return null;
  }

  Future<void> _upload() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final id = widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final url = await StorageService().uploadBytes(path: 'products/$id/${DateTime.now().millisecondsSinceEpoch}.jpg', bytes: bytes, contentType: 'image/jpeg');
      if (mounted) setState(() => _images.add(url));
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      showMessage(context, 'Choose a category');
      return;
    }
    setState(() => _saving = true);
    try {
      await FirestoreService().saveProduct(
        id: widget.product?.id,
        name: _name.text,
        brand: _brand.text,
        description: _description.text,
        categoryId: _categoryId!,
        price: int.parse(_price.text.trim()),
        discount: int.parse(_discount.text.trim()),
        stock: int.parse(_stock.text.trim()),
        images: _images,
        isAvailable: _available,
        popularity: int.parse(_popularity.text.trim()),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
