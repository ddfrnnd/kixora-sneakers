# 👟 Kixora Sneakers — Premium Footwear E-Commerce Mobile App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/Clean_Architecture-Provider-blue?style=for-the-badge)

**Kixora Sneakers** (SoleStep Footwear) is a modern, high-performance mobile e-commerce application built with Flutter & Dart. It delivers a seamless online shopping experience for sneaker enthusiasts and a comprehensive administrative dashboard for store managers.

---

## ✨ Key Features

### 🛍️ Shopper Experience
* **Dynamic Product Catalog**: Browse curated sneakers across categories (*Sneakers, Running, Casual, Formal*) with live search & interactive category filters.
* **Rich Product Detail Page**: High-resolution sneaker showcases, size selectors (EU 39–44), price formatting in IDR, and real-time customer review ratings.
* **Interactive Reviews & Ratings**: Verified buyers can submit permanent 1-time ratings & text reviews synchronized directly to Cloud Firestore.
* **Cart & Smart Checkout**: Interactive cart management with quantity controls and instant subtotal calculations.
* **GPS & OpenStreetMap Address Tagging**: Precision geolocation tagging (`geolocator`) and interactive map preview (`flutter_map`) for pin-point delivery address input.
* **Live Order Tracking**: Real-time order lifecycle tracking timeline (`New` ➔ `Processing` ➔ `In Delivery` ➔ `Completed`).
* **Instant Invoice/Receipt PDF Export**: Built-in PDF receipt generator (`pdf` & `printing`) allowing customers to download official transaction receipts.

### 🛡️ Store Admin Dashboard
* **5-Tab Comprehensive Management**:
  1. 📊 **Dashboard**: Real-time Executive KPI cards (Revenue, Active Orders, Products Sold, Success Rate) & Recent Order Feed.
  2. 👟 **Product Management**: Real-time Firestore sneaker catalog with instant Add Shoe & Delete Product capabilities.
  3. 📄 **Analytics & Reports**: Visual business analytics using `fl_chart` (Line Charts for Revenue Trends, Pie Charts for Order Status Distribution, and Bar Charts for Category Sales) + Official PDF Sales Report Export.
  4. 📦 **Order Dispatch**: Real-time status update switcher (`New`, `Processing`, `In Delivery`, `Completed`) synchronized live to the user's tracking screen.
  5. 👤 **Profile & Settings**: Store configurations, access control, and secure authentication management.

---

## 🛠️ Architecture & Tech Stack

This project strictly adheres to **Clean Architecture** principles and feature-driven folder structures:

```
lib/
├── app/                  # Theme tokens, global routes (GoRouter), & app entry
├── core/                 # Shared utilities, receipt generators, & constants
├── features/
│   ├── admin/            # Admin management, analytics (fl_chart), & order dispatch
│   ├── auth/             # Multi-role authentication & session state
│   ├── home/             # Main showcase, banner sliders, & discovery feed
│   ├── order/            # Cart, checkout, GPS tagging, & real-time tracking
│   ├── product/          # Sneakers catalog, product detail, & live review stream
│   └── profile/          # User address book & account settings
└── shared/               # Reusable UI components (buttons, textfields, cards)
```

* **Framework**: Flutter SDK ^3.11.5
* **State Management**: `provider` ^6.1.2
* **Navigation**: `go_router` ^14.8.1
* **Cloud Database & Auth**: `cloud_firestore` ^5.6.8, `firebase_core` ^3.13.0, `firebase_auth` ^5.5.3
* **Charts & Analytics**: `fl_chart` ^1.2.0
* **Maps & Geolocation**: `flutter_map` ^7.0.2, `latlong2` ^0.9.1, `geolocator` ^13.0.2
* **Document Export**: `pdf` ^3.11.1, `printing` ^5.13.2
* **Secure Persistence**: `flutter_secure_storage` ^9.2.4, `sqflite` ^2.4.2

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.11.5 or newer)
* Android Studio / VS Code
* Git

### Installation Guide

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ddfrnnd/kixora-sneakers.git
   cd kixora-sneakers
   ```

2. **Setup Environment Variables**
   Copy `.env.example` to `.env` in the root directory:
   ```bash
   cp .env.example .env
   ```
   Fill in your API keys and Firebase configurations inside `.env`.

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Developed with ❤️ by ddfrnnd.*
