import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.solestep.com/v1';

  // Kicks.dev API Configuration
  static String get kicksApiKey =>
      dotenv.env['KICKS_API_KEY'] ?? '';

  static String get kicksApiBaseUrl =>
      dotenv.env['KICKS_API_BASE_URL'] ?? 'https://api.kicks.dev/v3';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  static String get mapTileUrl =>
      dotenv.env['MAP_TILE_SERVER_URL'] ??
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String get mapUserAgent =>
      dotenv.env['MAP_USER_AGENT'] ?? 'com.solestep.app';

  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'toko-fashion-cc521';

  // Product endpoints
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';

  // Order endpoints
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static String updateOrderStatus(String id) => '/orders/$id/status';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
}
