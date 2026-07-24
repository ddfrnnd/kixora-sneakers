# Shoe E-Commerce App Design System & Specs (`design.md`)

## 1. Overview & UI Architecture
Aplikasi E-Commerce Sepatu berbasis *Mobile First* (iOS/Android) yang mengusung konsep **Light Theme**, **Clean**, **Modern**, dan **Minimalist**.

* **Target Device:** iPhone / Android Smartphone (Standard Resolution ~390px × 844px)
* **Primary Theme:** Light Mode
* **Design Philosophy:** High contrast typography, generous whitespace, soft rounded corners, and clear call-to-actions (CTA).

---

## 2. Typography Rules

* **Primary Font Family:** `Urbanist` (Google Fonts: Sans-Serif)
* **Fallback Fonts:** `Inter`, `Plus Jakarta Sans`, `system-ui`

| Level | Size | Weight | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Heading 1** | 24px | Bold (700) | 32px | Judul utama layar ("My Cart", "Checkout", "Notification") |
| **Heading 2** | 18px | Bold (700) | 24px | Judul seksi ("Special Offers", "Most Popular", "Sort & Filter") |
| **Title Medium**| 16px | SemiBold (600) | 22px | Nama Produk, Item Cart, Nama User ("Andrew Ainsley") |
| **Body Regular** | 14px | Regular (400) | 20px | Deskripsi produk, alamat pengiriman, isi ulasan |
| **Caption / Badge** | 12px | Medium (500) | 16px | Info rating, statistik (`6,937 sold`), subtitle sekunder |

---

## 3. Color Palette & Design Tokens

### **Primary & Neutral Colors**
| Token Name | Hex Code | Usage |
| :--- | :--- | :--- |
| `color-bg-primary` | `#FFFFFF` | Latar belakang utama aplikasi |
| `color-bg-secondary` | `#F8F9FA` | Container kartu produk, input field, & badge background |
| `color-surface-dark` | `#111111` | Primary CTA Button, Tab Aktif, & Text Utama |
| `color-text-secondary` | `#6C757D` | Subtitle, rating count, & placeholder text |
| `color-border` | `#E9ECEF` | Border halus pada chip & divider line |

### **Accent Colors**
| Token Name | Hex Code | Usage |
| :--- | :--- | :--- |
| `color-accent-red` | `#E53935` | Banner promo "Special Offers" & Diskon badge |
| `color-accent-star` | `#FFC107` | Rating Bintang |
| `color-swatch-blue` | `#4A6572` | Pilihan varian warna produk |
| `color-swatch-purple` | `#8E24AA` | Pilihan varian warna produk |
| `color-swatch-green` | `#2E7D32` | Pilihan varian warna produk |

---

## 4. Components Specs

### **4.1. Typography Styling Code (Urbanist)**
```css
/* Google Font Import */
@import url('https://fonts.googleapis.com/css2?family=Urbanist:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap');

body {
  font-family: 'Urbanist', sans-serif;
  color: #111111;
  background-color: #FFFFFF;
}
```

### **4.2. Buttons**
* **Primary Button:**
  * Height: `54px`
  * Corner Radius: `100px` (Full Pill/Capsule Shape)
  * Background: `#111111`
  * Text Color: `#FFFFFF` (Font Family: `Urbanist`, Size: 16px, Weight: Bold)
* **Secondary / Chip Button:**
  * Height: `38px`
  * Corner Radius: `100px`
  * Background (Active): `#111111` (Text White)
  * Background (Inactive): `#FFFFFF` with `1.5px` border `#111111` (Text Dark)

### **4.3. Cards & Containers**
* **Product Card:**
  * Background Image Container: `#F8F9FA` with Radius `20px`
  * Heart/Wishlist Icon: Circle `#111111` (Opacity 80%), Icon White, Top-Right positioned (`top: 12px`, `right: 12px`).
* **Promo Banner:**
  * Radius: `24px`
  * Gradient Background: Red Accent `#E53935` to Deep Burgundy `#B71C1C`.

### **4.4. Navigation & Bars**
* **Bottom Navigation Bar:**
  * Height: `70px` + safe area inset.
  * Border Top: `1px solid #F1F3F5`.
  * Active Tab Indicator: Icon & Text Color `#111111`.
  * Inactive Tab: Icon & Text Color `#9E9E9E`.

---

## 5. Screen Breakdown & Layout Specifications

```
├── 1. Home Screen (28_Light_home full page)
├── 2. Search & Filter (34-37)
│   ├── Search Overlay & Recent Keywords
│   ├── Empty State (Result Not Found)
│   ├── Search Results Grid
│   └── BottomSheet Sort & Filter Modal
├── 3. Product Details & Reviews (38-39)
│   ├── Detail View (Size, Color, Add to Cart)
│   └── Customer Reviews List Screen
├── 4. Cart & Checkout Flow
│   ├── Cart List & Item Removal Popup
│   ├── Checkout Summary & Shipping Options
│   └── Address Selector Screen
└── 5. Order Tracking & Reviews Flow
    ├── Orders List (Active vs Completed Tabs)
    ├── Delivery Tracking Timeline
    └── Leave Review BottomSheet
```

### **Detail Spesifikasi Alur (Flow Spec):**
1. **Home Screen:**
   - Search bar membuka `Search Overlay`.
   - Mengetuk kategori merek (misal: Nike) mengarahkan pengguna ke halaman filter brand `38_Light_nike`.
2. **Product Detail:**
   - Memilih varian warna/ukuran mengubah *state* terpilih (*active outline* pada swatch).
   - Tombol **Add to Cart** memicu popup indikator sukses atau membawa pengguna ke layar `My Cart`.
3. **Checkout & Payment:**
   - Alamat pengiriman dapat diubah secara modal (*BottomSheet*) atau beralih ke layar `Shipping Address`.
4. **Order Tracking:**
   - Menampilkan status logistik menggunakan komponen **Vertical Stepper** (*Packing*, *Shipped*, *Customs*, *In Transit*).
