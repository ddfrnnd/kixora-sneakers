import 'package:flutter/material.dart';
import 'package:fashion_ecommerce/core/database/database_helper.dart';
import 'package:fashion_ecommerce/core/network/network_info.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';
import 'package:fashion_ecommerce/features/product/data/datasources/kicks_remote_datasource.dart';
import 'package:fashion_ecommerce/features/product/data/datasources/product_local_datasource.dart';
import 'package:fashion_ecommerce/features/product/data/datasources/product_remote_datasource.dart';
import 'package:fashion_ecommerce/features/product/data/repositories/product_repository_impl.dart';
import 'package:fashion_ecommerce/features/product/domain/entities/product.dart';
import 'package:fashion_ecommerce/features/product/data/models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final NetworkInfo networkInfo;
  final DatabaseHelper dbHelper;

  final ProductRemoteDatasource _remoteDatasource = ProductRemoteDatasource();
  late final ProductRepositoryImpl _repository;
  final KicksRemoteDatasource _kicksDatasource = KicksRemoteDatasource();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Set<String> _favoriteIds = {};

  ProductProvider({
    required this.networkInfo,
    required this.dbHelper,
  }) {
    _repository = ProductRepositoryImpl(
      remoteDatasource: ProductRemoteDatasource(),
      localDatasource: ProductLocalDatasource(dbHelper: dbHelper),
      networkInfo: networkInfo,
    );
  }

  /// Sync live sneakers from Kicks.dev (kicks.dev API)
  Future<void> syncFromKicksDev({String query = 'jordan'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final kicksProducts = await _kicksDatasource.searchSneakers(query: query);
      if (kicksProducts.isNotEmpty) {
        await _remoteDatasource.saveProducts(kicksProducts);
        _repository.localDatasource.appendProducts(kicksProducts);
        _products = [...kicksProducts, ..._products];
        _applyFilters();
        AppLogger.success('Berhasil menambahkan ${kicksProducts.length} sepatu dari Kicks.dev!');
      } else {
        await fetchProducts();
      }
    } catch (e) {
      AppLogger.warning('Gagal sync dari Kicks.dev, memuat database lokal: $e');
      await fetchProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Fetch all products — dari Firestore, fallback ke SQLite, auto-sync dari Kicks jika kosong
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _repository.getAllProducts();
      _products = _products.where(KicksRemoteDatasource.isShoeProduct).toList();
      _products = _products.where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty).toList();
      if (_products.isEmpty) {
        await _syncDefaultBrands();
        _products = await _repository.getAllProducts();
        _products = _products.where(KicksRemoteDatasource.isShoeProduct).toList();
        _products = _products.where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty).toList();
      }
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync default brands dari Kicks.dev kalau Firestore masih kosong
  Future<void> _syncDefaultBrands() async {
    final brands = ['nike', 'adidas', 'jordan', 'new balance', 'puma', 'converse', 'vans'];
    for (final brand in brands) {
      try {
        final products = await _kicksDatasource.searchSneakers(query: brand);
        if (products.isNotEmpty) {
          await _remoteDatasource.saveProducts(products);
        }
      } catch (e) {
        AppLogger.warning('Sync brand $brand gagal: $e');
      }
    }
  }

  /// Fetch product detail
  Future<void> fetchProductDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Cek daftar produk di memori (termasuk produk live Kicks.dev)
      final inMemoryIndex = _products.indexWhere((p) => p.id == id);
      if (inMemoryIndex != -1) {
        _selectedProduct = _products[inMemoryIndex];
      } else {
        // 2. Fallback ke repository database
        _selectedProduct = await _repository.getProductById(id);
      }
    } catch (e) {
      _error = 'Gagal memuat detail sepatu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by category
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  /// Search products
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Apply category (Brand) + search filters
  void _applyFilters() {
    _ensureUniquePrices();
    _filteredProducts = _products;

    if (_selectedCategory != 'Semua' && _selectedCategory != 'All') {
      final queryLower = _selectedCategory.toLowerCase();
      _filteredProducts = _filteredProducts.where((p) {
        final catLower = p.category.toLowerCase();
        final nameLower = p.name.toLowerCase();
        return catLower.contains(queryLower) ||
               nameLower.contains(queryLower) ||
               queryLower.contains(catLower);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      _filteredProducts = _filteredProducts.where((p) {
        return p.name.toLowerCase().contains(searchLower) ||
               p.description.toLowerCase().contains(searchLower) ||
               p.category.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  /// Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
  }

  // Wishlist / Favorites methods
  Set<String> get favoriteIds => _favoriteIds;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  List<Product> get favoriteProducts {
    // Return unique favorites list matching in-memory products
    return _products.where((p) => _favoriteIds.contains(p.id)).toList();
  }

  void _ensureUniquePrices() {
    _products = _products.map((p) {
      final cleanName = p.name.replaceAll(RegExp(r'\s*\[Kicks?\.dev\]', caseSensitive: false), '').trim();
      double newPrice = p.price;
      if (p.price == 0 || p.price == 2150000.0 || p.price == 2250000.0) {
        final seed = '${p.id}$cleanName';
        final hash = seed.codeUnits.fold(0, (prev, elem) => prev + elem);
        final usd = 110.0 + ((hash % 19) * 10.0);
        newPrice = usd * 16200;
      }
      return ProductModel(
        id: p.id,
        name: cleanName,
        description: p.description,
        price: newPrice,
        category: p.category,
        imageUrl: p.imageUrl,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );
    }).toList();
  }
}
