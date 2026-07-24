# Struktur Folder Flutter — Aplikasi Toko Roti Online

Arsitektur: **Clean Architecture** dengan pendekatan **Feature-First**

---

```
toko_roti_app/
│
├── android/                            # Native Android config
│   └── app/
│       └── src/main/AndroidManifest.xml  # Tambah permission GPS & internet
│
├── ios/                                # (opsional, jika target iOS juga)
│
├── assets/
│   ├── images/                         # Gambar statis (logo, placeholder)
│   │   ├── logo.png
│   │   └── placeholder_roti.png
│   ├── icons/                          # Icon custom
│   └── fonts/                          # Custom font (jika ada)
│
├── lib/
│   │
│   ├── main.dart                       # Entry point aplikasi
│   │
│   ├── app/
│   │   ├── app.dart                    # MaterialApp + GoRouter setup
│   │   ├── routes/
│   │   │   └── app_router.dart         # Definisi semua route (GoRouter)
│   │   └── theme/
│   │       ├── app_theme.dart          # ThemeData (warna, font, shape)
│   │       ├── app_colors.dart         # Palet warna brand
│   │       └── app_text_styles.dart    # Typography scale
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # Base URL, endpoint strings
│   │   │   └── app_constants.dart      # Nilai konstan umum (timeout, dll)
│   │   │
│   │   ├── errors/
│   │   │   ├── exceptions.dart         # Custom exceptions (NetworkException, dll)
│   │   │   └── failures.dart           # Failure classes untuk Either<>
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart         # Singleton Dio instance + interceptors
│   │   │   └── network_info.dart       # Cek status koneksi internet
│   │   │
│   │   ├── database/
│   │   │   ├── database_helper.dart    # SQLite init & helper (sqflite)
│   │   │   └── migrations/
│   │   │       └── create_tables.dart  # DDL tabel SQLite
│   │   │
│   │   ├── storage/
│   │   │   └── secure_storage.dart     # Wrapper flutter_secure_storage
│   │   │
│   │   └── utils/
│   │       ├── logger.dart             # Logging utility
│   │       ├── validator.dart          # Validasi form (nama, HP, dll)
│   │       └── location_helper.dart    # Helper GPS (geolocator wrapper)
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── custom_button.dart      # Tombol reusable
│   │   │   ├── custom_text_field.dart  # Input field reusable
│   │   │   ├── loading_indicator.dart  # Spinner / shimmer
│   │   │   ├── error_widget.dart       # Widget tampilan error
│   │   │   ├── empty_state_widget.dart # Widget saat data kosong
│   │   │   └── product_card.dart       # Card produk (dipakai di katalog)
│   │   │
│   │   └── models/
│   │       └── api_response.dart       # Generic API response wrapper
│   │
│   └── features/
│       │
│       ├── splash/
│       │   ├── presentation/
│       │   │   └── splash_screen.dart
│       │   └── splash_controller.dart  # Cek token, routing awal
│       │
│       ├── home/
│       │   └── presentation/
│       │       └── home_screen.dart    # Landing page / navbar utama
│       │
│       ├── product/                    # ── FITUR KATALOG ──
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── product_remote_datasource.dart   # Ambil data dari API
│       │   │   │   └── product_local_datasource.dart    # Cache SQLite
│       │   │   ├── models/
│       │   │   │   └── product_model.dart               # JSON serializable
│       │   │   └── repositories/
│       │   │       └── product_repository_impl.dart
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── product.dart                     # Entity murni
│       │   │   ├── repositories/
│       │   │   │   └── product_repository.dart          # Abstract
│       │   │   └── usecases/
│       │   │       ├── get_all_products.dart
│       │   │       └── get_product_detail.dart
│       │   │
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── product_provider.dart            # State management
│       │       ├── screens/
│       │       │   ├── product_list_screen.dart         # Katalog (grid)
│       │       │   └── product_detail_screen.dart       # Detail + harga
│       │       └── widgets/
│       │           └── category_filter_chip.dart
│       │
│       ├── order/                      # ── FITUR PEMESANAN + GPS ──
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── order_remote_datasource.dart     # POST order ke API
│       │   │   ├── models/
│       │   │   │   ├── order_model.dart
│       │   │   │   └── order_item_model.dart
│       │   │   └── repositories/
│       │   │       └── order_repository_impl.dart
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── order.dart
│       │   │   ├── repositories/
│       │   │   │   └── order_repository.dart
│       │   │   └── usecases/
│       │   │       └── create_order.dart
│       │   │
│       │   └── presentation/
│       │       ├── providers/
│       │       │   ├── order_provider.dart
│       │       │   ├── cart_provider.dart               # Keranjang belanja
│       │       │   └── location_provider.dart           # GPS state
│       │       ├── screens/
│       │       │   ├── cart_screen.dart                 # Keranjang
│       │       │   ├── order_form_screen.dart           # Form + GPS
│       │       │   ├── order_confirmation_screen.dart   # Review sebelum submit
│       │       │   └── order_success_screen.dart        # Sukses
│       │       └── widgets/
│       │           ├── gps_location_card.dart           # Tampil koordinat GPS
│       │           └── map_preview_widget.dart          # Mini map lokasi
│       │
│       ├── auth/                       # ── FITUR LOGIN ADMIN ──
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── auth_remote_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── login_admin.dart
│       │   │       └── logout.dart
│       │   │
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart
│       │       └── screens/
│       │           └── login_screen.dart
│       │
│       └── admin/                      # ── PANEL ADMIN ──
│           ├── data/
│           │   ├── datasources/
│           │   │   └── admin_remote_datasource.dart     # GET semua order
│           │   ├── models/
│           │   │   └── order_detail_model.dart
│           │   └── repositories/
│           │       └── admin_repository_impl.dart
│           │
│           ├── domain/
│           │   ├── entities/
│           │   │   └── order_detail.dart
│           │   ├── repositories/
│           │   │   └── admin_repository.dart
│           │   └── usecases/
│           │       ├── get_all_orders.dart
│           │       └── update_order_status.dart
│           │
│           └── presentation/
│               ├── providers/
│               │   └── admin_provider.dart
│               ├── screens/
│               │   ├── admin_dashboard_screen.dart      # Daftar pesanan
│               │   └── admin_order_detail_screen.dart   # Detail + GPS
│               └── widgets/
│                   ├── order_status_badge.dart
│                   └── customer_location_map.dart       # Peta lokasi pelanggan
│
├── test/
│   ├── unit/
│   │   ├── product/
│   │   ├── order/
│   │   └── auth/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml                        # Dependensi Flutter
├── analysis_options.yaml               # Lint rules
├── .env                                # API keys (jangan di-commit!)
├── .gitignore
└── README.md
```

---

## pubspec.yaml — Dependencies

```yaml
name: toko_roti_app
description: Aplikasi pemesanan roti dan kue online — BNSP Junior Mobile Programmer

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.2           # atau: flutter_riverpod / flutter_bloc

  # Navigation
  go_router: ^13.0.0

  # HTTP & API
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1

  # Database Lokal
  sqflite: ^2.3.2
  path: ^1.9.0

  # Secure Storage
  flutter_secure_storage: ^9.0.0

  # SharedPreferences
  shared_preferences: ^2.2.2

  # GPS & Lokasi
  geolocator: ^11.0.0
  geocoding: ^2.1.1
  permission_handler: ^11.3.0

  # Maps
  google_maps_flutter: ^2.6.0   # atau flutter_map (open source)

  # Konektivitas
  connectivity_plus: ^5.0.2

  # UI
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9
  gap: ^3.0.1

  # JSON
  json_annotation: ^4.9.0

  # Env
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  mockito: ^5.4.4
```

---

## AndroidManifest.xml — Permission yang Diperlukan

```xml
<!-- Internet -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- GPS / Lokasi -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Koneksi jaringan -->
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- Kamera (opsional) -->
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## Urutan Pengerjaan yang Disarankan

```
1. Setup project & dependencies (pubspec.yaml)
2. Buat theme & color palette (app_theme.dart)
3. Setup routing (app_router.dart)
4. Core: DioClient, DatabaseHelper, SecureStorage
5. Feature: Product (data → domain → presentation)
6. Feature: Order + GPS integration
7. Feature: Auth (login admin)
8. Feature: Admin panel
9. Testing & polish UI
10. Build APK untuk demonstrasi
```
