import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_ecommerce/features/splash/presentation/splash_screen.dart';
import 'package:fashion_ecommerce/features/home/presentation/home_screen.dart';
import 'package:fashion_ecommerce/features/product/presentation/screens/product_list_screen.dart';
import 'package:fashion_ecommerce/features/product/presentation/screens/product_detail_screen.dart';
import 'package:fashion_ecommerce/features/product/presentation/screens/wishlist_screen.dart';
import 'package:fashion_ecommerce/features/product/presentation/screens/special_offers_screen.dart';
import 'package:fashion_ecommerce/features/product/presentation/screens/customer_reviews_screen.dart';
import 'package:fashion_ecommerce/features/profile/presentation/screens/address_list_screen.dart';
import 'package:fashion_ecommerce/features/profile/presentation/screens/add_new_address_screen.dart';
import 'package:fashion_ecommerce/features/order/presentation/screens/cart_screen.dart';
import 'package:fashion_ecommerce/features/order/presentation/screens/order_form_screen.dart';
import 'package:fashion_ecommerce/features/order/presentation/screens/order_confirmation_screen.dart';
import 'package:fashion_ecommerce/features/order/presentation/screens/order_success_screen.dart';
import 'package:fashion_ecommerce/features/order/presentation/screens/order_tracking_screen.dart';
import 'package:fashion_ecommerce/features/auth/presentation/screens/login_screen.dart';
import 'package:fashion_ecommerce/features/auth/presentation/screens/register_screen.dart';
import 'package:fashion_ecommerce/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:fashion_ecommerce/features/admin/presentation/screens/add_product_screen.dart';
import 'package:fashion_ecommerce/features/admin/presentation/screens/admin_order_detail_screen.dart';
import 'package:fashion_ecommerce/features/order/domain/entities/order.dart' as entity;
import 'package:hugeicons/hugeicons.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Products
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/products/brand/:brandName',
        name: 'brand-products',
        builder: (context, state) {
          final brand = state.pathParameters['brandName']!;
          return ProductListScreen(brand: brand);
        },
      ),
      GoRoute(
        path: '/products/:id',
        name: 'product-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/special-offers',
        name: 'special-offers',
        builder: (context, state) => const SpecialOffersScreen(),
      ),
      GoRoute(
        path: '/reviews',
        name: 'customer-reviews',
        builder: (context, state) => const CustomerReviewsScreen(),
      ),
      GoRoute(
        path: '/address',
        name: 'address-list',
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/address/add',
        name: 'add-new-address',
        builder: (context, state) => const AddNewAddressScreen(),
      ),

      // Cart & Order
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-form',
        name: 'order-form',
        builder: (context, state) => const OrderFormScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        builder: (context, state) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: '/order-success',
        name: 'order-success',
        builder: (context, state) {
          final extra = state.extra;
          entity.Order? order;
          if (extra is entity.Order) {
            order = extra;
          }
          return OrderSuccessScreen(order: order);
        },
      ),
      GoRoute(
        path: '/order-tracking/:id',
        name: 'order-tracking',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderTrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/order-tracking',
        name: 'order-tracking-extra',
        builder: (context, state) {
          final extra = state.extra;
          String id = '';
          if (extra is entity.Order) {
            id = extra.id ?? '';
          } else if (extra is String) {
            id = extra;
          }
          return OrderTrackingScreen(orderId: id);
        },
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Admin
      GoRoute(
        path: '/admin',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/add-product',
        name: 'admin-add-product',
        builder: (context, state) => const AddProductScreen(),
      ),
      GoRoute(
        path: '/admin/orders/:id',
        name: 'admin-order-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AdminOrderDetailScreen(orderId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  );
}
