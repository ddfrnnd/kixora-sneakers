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
  const AddProductScreen({super.key});

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

      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': price,
        'category': _selectedCategory,
        'image_url': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Refresh product provider list
        await context.read<ProductProvider>().fetchProducts();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk sepatu berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah sepatu: $e'),
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
        title: const Text('Tambah Sepatu Baru'),
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
              Text('Informasi Sepatu', style: AppTextStyles.h3),
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
                hint: 'Jelaskan material upper, bantalan, dan keunggulan...',
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
                  if (val == null || val.trim().isEmpty) return 'Harga tidak boleh kosong';
                  if (double.tryParse(val.trim()) == null) return 'Harga harus berupa angka';
                  return null;
                },
                keyboardType: TextInputType.number,
                prefixIcon: const HugeIcon(icon: HugeIcons.strokeRoundedMoney01),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              Text('Kategori', style: AppTextStyles.labelLarge),
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
                    items: const [
                      DropdownMenuItem(value: 'Sneakers', child: Text('👟 Sneakers')),
                      DropdownMenuItem(value: 'Running', child: Text('🏃 Running')),
                      DropdownMenuItem(value: 'Casual', child: Text('👞 Casual')),
                      DropdownMenuItem(value: 'Formal', child: Text('💼 Formal')),
                    ],
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
                text: 'Simpan Sepatu',
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
