import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/profile/data/models/address_item.dart';
import 'package:fashion_ecommerce/features/profile/data/repositories/address_repository.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final AddressRepository _addressRepository = AddressRepository();
  List<AddressItem> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final addresses = await _addressRepository.getAddresses();
    if (!mounted) return;
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Future<void> _setDefaultAddress(String id) async {
    await _addressRepository.setDefaultAddress(id);
    setState(() {
      for (var item in _addresses) {
        item.isDefault = (item.id == id);
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alamat utama berhasil diperbarui!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddEditAddressDialog({AddressItem? itemToEdit}) {
    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final addressController = TextEditingController(text: itemToEdit?.fullAddress ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                itemToEdit == null ? 'Tambah Alamat Baru' : 'Edit Alamat',
                style: AppTextStyles.h3.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Label Alamat (contoh: Rumah, Kantor)',
                  prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedTag01,
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap & Kode Pos',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLocation01,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final fullAddr = addressController.text.trim();

                    if (title.isNotEmpty && fullAddr.isNotEmpty) {
                      final address = itemToEdit ??
                          AddressItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: title,
                            fullAddress: fullAddr,
                            isDefault: _addresses.isEmpty,
                          );
                      address.title = title;
                      address.fullAddress = fullAddr;
                      await _addressRepository.saveAddress(address);
                      await _loadAddresses();
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            itemToEdit == null ? 'Alamat baru berhasil ditambahkan!' : 'Alamat berhasil diperbarui!',
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    itemToEdit == null ? 'Simpan Alamat' : 'Perbarui Alamat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (itemToEdit != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeleteAddress(itemToEdit);
                    },
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete02,
                      color: AppColors.error,
                      size: 18,
                    ),
                    label: const Text(
                      'Hapus Alamat Ini',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openAddNewAddressScreen() async {
    final result = await context.push<AddressItem>('/address/add');
    if (result != null) {
      setState(() {
        _addresses.removeWhere((item) => item.id == result.id);
        if (result.isDefault || _addresses.isEmpty) {
          for (var item in _addresses) {
            item.isDefault = false;
          }
          result.isDefault = true;
        }
        _addresses.insert(0, result);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alamat "${result.title}" berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Address',
          style: AppTextStyles.h2.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // Address Cards Scrollable List
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_addresses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Belum ada alamat tersimpan. Tambahkan alamat agar bisa dipakai saat checkout.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
            itemCount: _addresses.length,
            itemBuilder: (context, index) {
              final address = _addresses[index];
              return _buildAddressCard(address);
            },
            ),

          // Sticky Footer Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _openAddNewAddressScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      'Add New Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressItem address) {
    return GestureDetector(
      onTap: () => _setDefaultAddress(address.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: address.isDefault ? AppColors.primary : const Color(0xFFFAFAFA),
            width: address.isDefault ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Location Pin Icon Avatar (Stitch UI)
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E8E8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Title & Address Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.title,
                        style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        const DefaultAddressBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF757575),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),

            // Edit Pencil Action Button
            IconButton(
              onPressed: () => _showAddEditAddressDialog(itemToEdit: address),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedPencilEdit02,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),

            // Delete Trash Action Button
            IconButton(
              onPressed: () => _confirmDeleteAddress(address),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAddress(AddressItem address) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('Hapus Alamat', style: AppTextStyles.h3),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus alamat "${address.title}"? Tindakan ini tidak dapat dibatalkan.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _addressRepository.deleteAddress(address.id);
                await _loadAddresses();

                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alamat "${address.title}" berhasil dihapus.'),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

/// Clean Minimal Badge Tag for Default Address (Stitch UI)
class DefaultAddressBadge extends StatelessWidget {
  const DefaultAddressBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Default',
        style: TextStyle(
          color: Color(0xFF4A4A4A),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
