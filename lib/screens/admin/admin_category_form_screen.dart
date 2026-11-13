import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/category_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../widgets/baby_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  const AdminCategoryFormScreen({super.key, this.category});

  final Category? category;

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.category?.categoryName ?? '');
  late final TextEditingController _image = TextEditingController(text: widget.category?.categoryImage ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category == null ? 'Add category' : 'Edit category')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                BabyTextField(controller: _name, label: 'Category name', validator: (value) => Validators.requiredField(value, label: 'Name')),
                const SizedBox(height: 12),
                BabyTextField(controller: _image, label: 'Image URL'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _upload, child: const Text('Upload category image')),
          const SizedBox(height: 12),
          CustomButton(label: 'Save category', loading: _saving, onPressed: _save),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (file == null) return;
    final Uint8List bytes = await file.readAsBytes();
    final id = widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final url = await StorageService().uploadBytes(path: 'categories/$id/image.jpg', bytes: bytes, contentType: 'image/jpeg');
      if (mounted) setState(() => _image.text = url);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await FirestoreService().saveCategory(id: widget.category?.id, name: _name.text, image: _image.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
