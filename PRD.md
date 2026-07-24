# PRD — Aplikasi Toko Roti Online (Junior Mobile Programmer)

**Skema Sertifikasi**: Junior Mobile Programmer  
**Nomor SKM**: SKM/0317/00010/2/2019/19  
**Platform**: Flutter (Android)  
**Tanggal Dibuat**: 2025  

---

## 1. Ringkasan Produk

Aplikasi mobile berbasis Android yang dibangun dengan Flutter untuk memungkinkan pelanggan memesan roti dan kue secara online dari sebuah perusahaan bakery. Aplikasi mencakup fitur katalog produk, pemesanan berbasis GPS, dan panel admin untuk manajemen order.

---

## 2. Tujuan Produk

| Tujuan | Deskripsi |
|--------|-----------|
| **Bisnis** | Digitalisasi penjualan roti & kue, memperluas jangkauan pelanggan secara online |
| **Pelanggan** | Memudahkan pemesanan dengan informasi produk yang jelas dan proses yang cepat |
| **Admin** | Mempermudah monitoring dan pengelolaan pesanan masuk |

---

## 3. Pengguna (User Personas)

### 3.1 Pelanggan (Customer)
- Bisa melihat katalog produk (roti & kue)
- Bisa melihat detail produk beserta harga
- Bisa melakukan pemesanan
- Memberikan data diri dan koordinat GPS lokasi rumah
- Tidak perlu login (order as guest) — opsional: bisa daftar akun

### 3.2 Admin
- Login menggunakan akun khusus admin
- Melihat daftar semua pesanan masuk
- Melihat detail pesanan termasuk lokasi GPS pelanggan
- Mengelola status pesanan

---

## 4. Fitur & Modul

### 4.1 Modul Produk (Katalog)
**Unit Kompetensi**: J.612000.007.01 — Merancang Mobile Interface

| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-01 | Tampilkan daftar produk (grid/list) roti & kue | Wajib |
| F-02 | Detail produk: nama, deskripsi, harga, foto | Wajib |
| F-03 | Filter produk berdasarkan kategori (roti / kue) | Opsional |
| F-04 | Pencarian produk | Opsional |

**Desain UI yang disyaratkan:**
- Menentukan tools perancangan antarmuka (Flutter Widgets)
- Memilih informasi yang ditampilkan sesuai kebutuhan
- Membuat desain yang estetis dan fungsional per layar

---

### 4.2 Modul Pemesanan (Order)
**Unit Kompetensi**: J.612000.006.01 — Location Based Service & GPS

| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-05 | Form pemesanan: nama, nomor HP, alamat | Wajib |
| F-06 | Pengambilan koordinat GPS otomatis dari smartphone | Wajib |
| F-07 | Tampilkan peta lokasi pelanggan (Google Maps / OpenStreetMap) | Wajib |
| F-08 | Konfirmasi pesanan sebelum dikirim ke server | Wajib |
| F-09 | Riwayat pesanan pelanggan | Opsional |

**Catatan GPS:**
- Minta izin `ACCESS_FINE_LOCATION` dan `ACCESS_COARSE_LOCATION`
- Gunakan `geolocator` package Flutter
- Koordinat (latitude, longitude) wajib dikirim bersama data pesanan

---

### 4.3 Modul Database & Storage
**Unit Kompetensi**: J.612000.003.01 — Database & Data Persistence

| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-10 | Simpan data produk dari API server (REST) | Wajib |
| F-11 | Cache produk lokal dengan SQLite (via `sqflite`) | Wajib |
| F-12 | Simpan preferensi pengguna dengan SharedPreferences | Wajib |
| F-13 | Upload data pesanan ke server (REST API / Firebase) | Wajib |

**Strategi Storage:**
```
Internal Storage  → SharedPreferences (token, user prefs)
SQLite            → Cache produk & order lokal (sqflite)
External/Server   → REST API atau Firebase Firestore
```

---

### 4.4 Modul Admin
| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-14 | Login admin (email + password) | Wajib |
| F-15 | Dashboard daftar pesanan masuk | Wajib |
| F-16 | Detail pesanan: data pelanggan + koordinat GPS | Wajib |
| F-17 | Update status pesanan (Baru / Diproses / Selesai) | Opsional |
| F-18 | Lihat lokasi pelanggan di peta | Opsional |

---

### 4.5 Modul Autentikasi & Keamanan
**Unit Kompetensi**: J.612000.008.01 — Mobile Security

| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-19 | Login admin dengan JWT Token | Wajib |
| F-20 | HTTPS untuk semua komunikasi API | Wajib |
| F-21 | Validasi input form (client-side) | Wajib |
| F-22 | Simpan token secara aman (`flutter_secure_storage`) | Wajib |

---

### 4.6 Modul Sensor & Platform
**Unit Kompetensi**: J.612000.022.01 — Mobile Sensor

| ID | Fitur | Prioritas |
|----|-------|-----------|
| F-23 | Akses sensor GPS (geolocator) | Wajib |
| F-24 | Akses kamera/gallery untuk foto profil (opsional) | Opsional |
| F-25 | Deteksi koneksi jaringan (`connectivity_plus`) | Wajib |

---

## 5. Alur Aplikasi (User Flow)

### Flow Pelanggan
```
Splash Screen
    └─> Home / Katalog Produk
            ├─> Detail Produk
            │       └─> Tambah ke Keranjang
            │               └─> Form Pemesanan
            │                       ├─> Ambil GPS Otomatis
            │                       └─> Konfirmasi & Submit Order
            │                               └─> Halaman Sukses
            └─> Cari Produk (opsional)
```

### Flow Admin
```
Login Admin
    └─> Dashboard Pesanan
            └─> Detail Pesanan
                    ├─> Data Pelanggan
                    ├─> Lokasi GPS (peta)
                    └─> Update Status
```

---

## 6. Arsitektur Teknis

### Stack Teknologi

| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Provider / Riverpod / Bloc (pilih salah satu) |
| Navigasi | GoRouter |
| HTTP Client | `dio` atau `http` |
| Database Lokal | `sqflite` |
| Secure Storage | `flutter_secure_storage` |
| GPS | `geolocator` + `geocoding` |
| Maps | `google_maps_flutter` atau `flutter_map` |
| Backend | Firebase / REST API Node.js / Laravel |

### Arsitektur Folder (Clean Architecture)
```
lib/
├── core/                        # Konfigurasi inti
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/                    # Login admin
│   ├── product/                 # Katalog roti & kue
│   ├── order/                   # Pemesanan + GPS
│   ├── admin/                   # Panel admin
│   └── home/                    # Landing & splash
└── shared/
    ├── widgets/
    └── theme/
```

---

## 7. Spesifikasi API (Endpoint)

### Base URL: `https://api.toko-roti.com/v1`

| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/products` | Ambil semua produk | - |
| GET | `/products/:id` | Detail produk | - |
| POST | `/orders` | Buat pesanan baru | - |
| GET | `/orders` | Daftar semua pesanan | Admin |
| GET | `/orders/:id` | Detail pesanan | Admin |
| PATCH | `/orders/:id/status` | Update status pesanan | Admin |
| POST | `/auth/login` | Login admin | - |

### Payload POST `/orders`
```json
{
  "customer_name": "string",
  "customer_phone": "string",
  "address": "string",
  "latitude": 0.000000,
  "longitude": 0.000000,
  "items": [
    {
      "product_id": "string",
      "quantity": 1
    }
  ]
}
```

---

## 8. Persyaratan Non-Fungsional

| Kategori | Persyaratan |
|----------|-------------|
| **Platform** | Android (min SDK 21 / Android 5.0) |
| **Performa** | Cold start < 3 detik |
| **Keamanan** | HTTPS wajib, token disimpan aman |
| **Offline** | Produk ter-cache lokal via SQLite |
| **GPS** | Akurasi ≤ 50 meter |
| **Jaringan** | Minimal 4G+ / 10 Mbps (sesuai skenario) |
| **Ukuran APK** | < 50 MB |

---

## 9. Spesifikasi Perangkat Minimum (Sesuai Soal)

| Komponen | Spesifikasi |
|----------|-------------|
| Prosesor | Intel i3 atau setara |
| HDD | 256 GB |
| RAM | 4 GB |
| Software | Android Studio (versi terbaru) + AVD / HP Android |
| Internet | 10 Mbps atau 4G+ dengan kuota minimal 2 GB |

---

## 10. Unit Kompetensi yang Dicakup

| Kode Unit | Judul Unit | Fitur Terkait |
|-----------|-----------|---------------|
| J.612000.001.01 | Platform OS & Bahasa Pemrograman | Flutter / Dart, Android |
| J.612000.003.01 | Database & Data Persistence | SQLite, SharedPreferences, API |
| J.612000.006.01 | Location Based Service & GPS | GPS, Maps |
| J.612000.007.01 | Merancang Mobile Interface | UI/UX semua layar |
| J.612000.008.01 | Mobile Security | JWT, HTTPS, Secure Storage |
| J.612000.022.01 | Mobile Sensor | GPS Sensor, Connectivity |
| J.612000.025.01 | Mobile Cellular Network | Koneksi API via jaringan seluler |

---

## 11. Kriteria Penerimaan (Acceptance Criteria)

- [ ] Aplikasi dapat menampilkan daftar roti dan kue dari server
- [ ] Pengguna dapat melihat detail produk beserta harga
- [ ] Pengguna dapat melakukan pemesanan dengan form yang valid
- [ ] GPS berhasil mengambil koordinat lokasi pelanggan secara otomatis
- [ ] Data pesanan (termasuk koordinat GPS) berhasil tersimpan di server
- [ ] Admin dapat login dan melihat seluruh data pesanan
- [ ] Admin dapat melihat detail pesanan termasuk lokasi pelanggan
- [ ] Aplikasi menggunakan HTTPS untuk semua komunikasi
- [ ] Token admin tersimpan aman menggunakan `flutter_secure_storage`
- [ ] Produk ter-cache lokal saat tidak ada koneksi internet
