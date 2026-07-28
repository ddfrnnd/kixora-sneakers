import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/core/utils/validator.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_button.dart';
import 'package:fashion_ecommerce/shared/widgets/custom_text_field.dart';
import 'package:hugeicons/hugeicons.dart';

class AddProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? initialData;

  const AddProductScreen({
    super.key,
    this.productId,
    this.initialData,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Sneakers';
  bool _isLoading = false;

  bool get _isEditing => widget.productId != null && widget.productId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _descController.text = widget.initialData!['description'] ?? '';
      final rawPrice = widget.initialData!['price'];
      if (rawPrice != null) {
        _priceController.text = (rawPrice is num) ? rawPrice.toStringAsFixed(0) : rawPrice.toString();
      }
      _imageUrlController.text = widget.initialData!['image_url'] ?? widget.initialData!['imageUrl'] ?? '';
      final cat = widget.initialData!['category']?.toString() ?? 'Sneakers';
      _selectedCategory = _allowedCategories.contains(cat) ? cat : 'Sneakers';
    }
  }

  static const List<String> _allowedCategories = [
    'Sneakers',
    'Running',
    'Casual',
    'Formal',
    'Nike',
    'Adidas',
    'Jordan',
    'Puma',
    'Converse',
    'Vans',
    'New Balance',
    'Reebok',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final imageUrl = _imageUrlController.text.trim().isEmpty
          ? 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600'
          : _imageUrlController.text.trim();

      final payload = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': price,
        'category': _selectedCategory,
        'image_url': imageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(payload);
      } else {
        payload['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('products').add(payload);
      }

      if (!mounted) return;
      final productProvider = context.read<ProductProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final nav = context;
      await productProvider.fetchProducts();

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Data sepatu berhasil diperbarui.' : 'Sepatu baru berhasil ditambahkan!'),
          backgroundColor: AppColors.success,
        ),
      );
      nav.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Gagal mengedit sepatu.' : 'Gagal menambah sepatu.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Sepatu' : 'Tambah Sepatu Baru'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Produk', style: AppTextStyles.h3),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Nama Sepatu',
                hint: 'Contoh: Nike Air Max 90',
                controller: _nameController,
                validator: (val) => Validator.validateRequired(val, 'Nama sepatu'),
                prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedSwatch),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Deskripsi & Spesifikasi',
                hint: 'Tuliskan material upper, bantalan, dan keunggulan...',
                controller: _descController,
                validator: (val) => Validator.validateRequired(val, 'Deskripsi'),
                maxLines: 3,
                prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedFile01),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Harga (Rp)',
                hint: 'Contoh: 1500000',
                controller: _priceController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Harga wajib diisi';
                  if (double.tryParse(val.trim()) == null) return 'Harga harus berupa angka';
                  return null;
                },
                keyboardType: TextInputType.number,
                prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedMoney01),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              Text('Kategori / Brand', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _allowedCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'URL Gambar Sepatu (Opsional)',
                hint: 'https://images.unsplash.com/...',
                controller: _imageUrlController,
                prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedImage01),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: _isEditing ? 'Simpan Perubahan' : 'Simpan Sepatu Baru',
                icon: HugeIcons.strokeRoundedSave,
                isLoading: _isLoading,
                onPressed: _submitProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
