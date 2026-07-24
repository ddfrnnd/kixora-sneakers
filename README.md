# 👟 SoleStep Footwear — Shoe E-Commerce App UI

Aplikasi E-Commerce Sepatu berbasis Flutter Mobile (Android/iOS) yang mengusung desain **SoleStep Footwear App UI Design System** (*Clean, Minimalist, High Contrast Typography*).

## 📌 Fitur Utama:
1. **Katalog & Detail Sepatu**:
   - Menampilkan kategori: **Sneakers**, **Running**, **Casual**, **Formal**.
   - Detail spesifikasi sepatu, harga (Rp), foto HD, dan jumlah pesanan.
   - Filter kategori dan fitur pencarian nama/merk sepatu.

2. **Pemesanan Berbasis Location-Based Service (GPS)**:
   - Pengambilan lokasi GPS otomatis (`geolocator`).
   - Pratinjau peta interaktif (`flutter_map` - OpenStreetMap).
   - Layar konfirmasi checkout & pesanan sukses.

3. **Multi-User Autentikasi (Firebase Auth)**:
   - Registrasi & Login Pelanggan.
   - Login khusus Admin Store.
   - Penyimpanan token terenkripsi (`flutter_secure_storage`).

4. **Dashboard Admin Store**:
   - Memantau pesanan masuk secara *realtime*.
   - Pratinjau koordinat lokasi pelanggan di peta.
   - Update status pesanan (*Baru*, *Diproses*, *Selesai*).
   - Form **Tambah Sepatu Baru** langsung ke Cloud Firestore.

5. **Storage & Multi-Layer Persistence**:
   - Database Cloud: Firebase Firestore.
   - Offline Cache: SQLite (`sqflite`).
   - Secure Storage: `flutter_secure_storage`.

---
*Dibuat untuk Skema Sertifikasi BNSP Junior Mobile Programmer.*
