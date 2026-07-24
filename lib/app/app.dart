import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_ecommerce/app/theme/app_theme.dart';
import 'package:fashion_ecommerce/app/routes/app_router.dart';
import 'package:fashion_ecommerce/features/product/presentation/providers/product_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/cart_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/order_provider.dart';
import 'package:fashion_ecommerce/features/order/presentation/providers/location_provider.dart';
import 'package:fashion_ecommerce/features/auth/presentation/providers/auth_provider.dart';
import 'package:fashion_ecommerce/features/admin/presentation/providers/admin_provider.dart';
import 'package:fashion_ecommerce/core/network/network_info.dart';
import 'package:fashion_ecommerce/core/storage/secure_storage.dart';
import 'package:fashion_ecommerce/core/database/database_helper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final secureStorage = SecureStorage();
    final networkInfo = NetworkInfo();
    final dbHelper = DatabaseHelper.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            networkInfo: networkInfo,
            dbHelper: dbHelper,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            networkInfo: networkInfo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            secureStorage: secureStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'SoleStep Footwear',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
