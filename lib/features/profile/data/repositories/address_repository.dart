import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_ecommerce/core/database/database_helper.dart';
import 'package:fashion_ecommerce/features/profile/data/models/address_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AddressRepository {
  AddressRepository({
    DatabaseHelper? dbHelper,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final DatabaseHelper _dbHelper;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? get _remoteAddressesRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('addresses');
  }

  String get _cacheKey => 'profile_addresses_${_auth.currentUser?.uid ?? 'guest'}';

  Future<List<AddressItem>> getAddresses() async {
    final remoteRef = _remoteAddressesRef;
    if (remoteRef != null) {
      try {
        final snapshot = await remoteRef.orderBy('is_default', descending: true).orderBy('updated_at', descending: true).get();
        final addresses = snapshot.docs.map((doc) {
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
        await _replaceLocalCache(addresses);
        await _savePrefsCache(addresses);
        return addresses;
      } catch (_) {}
    }

    final db = await _dbHelper.database;
    if (db == null) return _getPrefsCache();

    final rows = await db.query(
      'addresses',
      orderBy: 'is_default DESC, created_at DESC',
    );
    final addresses = rows.map(AddressItem.fromMap).toList();
    return addresses.isNotEmpty ? addresses : _getPrefsCache();
  }

  Future<void> saveAddress(AddressItem address) async {
    final db = await _dbHelper.database;
    final remoteRef = _remoteAddressesRef;

    if (remoteRef != null) {
      if (address.isDefault) {
        await _clearRemoteDefaults(remoteRef);
      }
      await remoteRef.doc(address.id).set(address.toFirestore(), SetOptions(merge: true));
    }

    if (db == null) {
      await _upsertPrefsCache(address);
      return;
    }

    if (address.isDefault) {
      await db.update('addresses', {'is_default': 0});
    }

    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM addresses')) ?? 0;
    final data = address.toMap();
    if (count == 0) data['is_default'] = 1;

    await db.insert('addresses', data, conflictAlgorithm: ConflictAlgorithm.replace);
    await _upsertPrefsCache(address);
  }

  Future<void> setDefaultAddress(String id) async {
    final db = await _dbHelper.database;
    final remoteRef = _remoteAddressesRef;

    if (remoteRef != null) {
      await _clearRemoteDefaults(remoteRef);
      await remoteRef.doc(id).set({
        'is_default': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }

    if (db == null) {
      await _setPrefsDefaultAddress(id);
      return;
    }

    await db.transaction((txn) async {
      await txn.update('addresses', {'is_default': 0});
      await txn.update('addresses', {'is_default': 1}, where: 'id = ?', whereArgs: [id]);
    });
    await _setPrefsDefaultAddress(id);
  }

  Future<void> deleteAddress(String id) async {
    final db = await _dbHelper.database;
    final remoteRef = _remoteAddressesRef;

    if (remoteRef != null) {
      final doc = await remoteRef.doc(id).get();
      final wasRemoteDefault = doc.exists && doc.data()?['is_default'] == true;
      await remoteRef.doc(id).delete();
      if (wasRemoteDefault) {
        final remaining = await remoteRef.orderBy('updated_at', descending: true).limit(1).get();
        if (remaining.docs.isNotEmpty) {
          await remaining.docs.first.reference.set({
            'is_default': true,
            'updated_at': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
        }
      }
    }

    if (db == null) {
      await _deletePrefsAddress(id);
      return;
    }

    final existing = await db.query('addresses', where: 'id = ?', whereArgs: [id], limit: 1);
    final wasDefault = existing.isNotEmpty && existing.first['is_default'] == 1;

    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);

    if (wasDefault) {
      final remaining = await db.query('addresses', orderBy: 'created_at DESC', limit: 1);
      if (remaining.isNotEmpty) {
        await setDefaultAddress(remaining.first['id'].toString());
      }
    }
    await _deletePrefsAddress(id);
  }

  Future<void> _clearRemoteDefaults(CollectionReference<Map<String, dynamic>> remoteRef) async {
    final defaults = await remoteRef.where('is_default', isEqualTo: true).get();
    final batch = _firestore.batch();
    for (final doc in defaults.docs) {
      batch.update(doc.reference, {'is_default': false});
    }
    await batch.commit();
  }

  Future<void> _replaceLocalCache(List<AddressItem> addresses) async {
    final db = await _dbHelper.database;
    if (db == null) return;

    await db.transaction((txn) async {
      await txn.delete('addresses');
      for (final address in addresses) {
        await txn.insert('addresses', address.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<AddressItem>> _getPrefsCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AddressItem.fromMap)
          .toList()
        ..sort((a, b) {
          if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
          return b.id.compareTo(a.id);
        });
    } catch (_) {
      return [];
    }
  }

  Future<void> _savePrefsCache(List<AddressItem> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(addresses.map((item) => item.toMap()).toList()));
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
