import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'solestep_footwear.db';
  static const int _dbVersion = 2;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database?> _initDatabase() async {
    if (kIsWeb) return null;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel produk untuk cache lokal
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Tabel order lokal (untuk offline support)
    await db.execute('''
      CREATE TABLE orders(
        id TEXT PRIMARY KEY,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Baru',
        total_price REAL,
        created_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Tabel order items
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await _createAddressesTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAddressesTable(db);
    }
  }

  Future<void> _createAddressesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS addresses(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        full_address TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db?.close();
    _database = null;
  }
}
