import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/features/profile/data/models/address_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressRepository {
  AddressRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? get _remoteAddressesRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('addresses');
  }

  String get _currentUid => _auth.currentUser?.uid ?? 'guest';
  String get _cacheKey => 'profile_addresses_$_currentUid';

  /// Ambil daftar alamat milik pengguna aktif (terintegrasi dengan Firestore Database)
  Future<List<AddressItem>> getAddresses() async {
    final user = _auth.currentUser;
    final remoteRef = _remoteAddressesRef;

    if (user != null && remoteRef != null) {
      try {
        // Query tanpa komposit indeks agar 100% handal & tanpa error Firestore
        final snapshot = await remoteRef.get();
        final List<AddressItem> addresses = snapshot.docs.map((doc) {
          final data = doc.data();
          return AddressItem(
            id: doc.id,
            title: data['title']?.toString() ?? '',
            fullAddress: data['full_address']?.toString() ?? '',
            latitude: (data['latitude'] as num?)?.toDouble(),
            longitude: (data['longitude'] as num?)?.toDouble(),
            isDefault: data['is_default'] == true,
          );
        }).toList();

        // Urutkan alamat utama (default) paling atas
        addresses.sort((a, b) {
          if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
          return b.id.compareTo(a.id);
        });

        await _savePrefsCache(addresses);
        return addresses;
      } catch (_) {}
    }

    // Jika offline atau belum terautentikasi, ambil dari penyimpanan lokal berisikan UID pengguna
    return _getPrefsCache();
  }

  /// Simpan atau perbarui alamat ke Firestore Database & lokal HP
  Future<void> saveAddress(AddressItem address) async {
    final user = _auth.currentUser;
    final remoteRef = _remoteAddressesRef;

    if (user != null && remoteRef != null) {
      try {
        if (address.isDefault) {
          await _clearRemoteDefaults(remoteRef);
        }
        await remoteRef.doc(address.id).set(
          address.toFirestore(),
          SetOptions(merge: true),
        );

        // Update alamat default di profil utama user jika alamat utama
        if (address.isDefault) {
          await _firestore.collection('users').doc(user.uid).set({
            'address': address.fullAddress,
            'latitude': address.latitude,
            'longitude': address.longitude,
          }, SetOptions(merge: true));
        }
      } catch (_) {}
    }

    await _upsertPrefsCache(address);
  }

  /// Atur alamat utama (Default Address)
  Future<void> setDefaultAddress(String id) async {
    final user = _auth.currentUser;
    final remoteRef = _remoteAddressesRef;

    if (user != null && remoteRef != null) {
      try {
        await _clearRemoteDefaults(remoteRef);
        await remoteRef.doc(id).set({
          'is_default': true,
          'updated_at': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));

        // Ambil alamat untuk sinkron ke profil utama
        final doc = await remoteRef.doc(id).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          await _firestore.collection('users').doc(user.uid).set({
            'address': data['full_address'] ?? '',
            'latitude': (data['latitude'] as num?)?.toDouble(),
            'longitude': (data['longitude'] as num?)?.toDouble(),
          }, SetOptions(merge: true));
        }
      } catch (_) {}
    }

    await _setPrefsDefaultAddress(id);
  }

  /// Hapus alamat
  Future<void> deleteAddress(String id) async {
    final remoteRef = _remoteAddressesRef;

    if (remoteRef != null) {
      try {
        final doc = await remoteRef.doc(id).get();
        final wasRemoteDefault = doc.exists && doc.data()?['is_default'] == true;
        await remoteRef.doc(id).delete();

        if (wasRemoteDefault) {
          final remaining = await remoteRef.limit(1).get();
          if (remaining.docs.isNotEmpty) {
            await remaining.docs.first.reference.set({
              'is_default': true,
              'updated_at': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
          }
        }
      } catch (_) {}
    }

    await _deletePrefsAddress(id);
  }

  Future<void> _clearRemoteDefaults(CollectionReference<Map<String, dynamic>> remoteRef) async {
    try {
      final defaults = await remoteRef.where('is_default', isEqualTo: true).get();
      final batch = _firestore.batch();
      for (final doc in defaults.docs) {
        batch.update(doc.reference, {'is_default': false});
      }
      await batch.commit();
    } catch (_) {}
  }

  // ── LOCAL PREFERENCES CACHE PER USER ────────────────────────────────────────

  Future<List<AddressItem>> _getPrefsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(AddressItem.fromMap)
          .toList();

      list.sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        return b.id.compareTo(a.id);
      });
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePrefsCache(List<AddressItem> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(addresses.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> _upsertPrefsCache(AddressItem address) async {
    final addresses = await _getPrefsCache();
    final index = addresses.indexWhere((item) => item.id == address.id);
    final shouldSetDefault = address.isDefault || addresses.isEmpty;

    if (shouldSetDefault) {
      for (final item in addresses) {
        item.isDefault = false;
      }
      address.isDefault = true;
    }

    if (index == -1) {
      addresses.insert(0, address);
    } else {
      addresses[index] = address;
    }

    await _savePrefsCache(addresses);
  }

  Future<void> _setPrefsDefaultAddress(String id) async {
    final addresses = await _getPrefsCache();
    for (final item in addresses) {
      item.isDefault = item.id == id;
    }
    await _savePrefsCache(addresses);
  }

  Future<void> _deletePrefsAddress(String id) async {
    final addresses = await _getPrefsCache();
    final removedIndex = addresses.indexWhere((item) => item.id == id);
    final wasDefault = removedIndex != -1 && addresses[removedIndex].isDefault;
    addresses.removeWhere((item) => item.id == id);
    if (wasDefault && addresses.isNotEmpty) {
      addresses.first.isDefault = true;
    }
    await _savePrefsCache(addresses);
  }
}
