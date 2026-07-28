import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.isInitialized ? (dotenv.env['API_BASE_URL'] ?? 'https://api.solestep.com/v1') : 'https://api.solestep.com/v1';

  // Kicks.dev API Configuration
  static String get kicksApiKey =>
      dotenv.isInitialized ? (dotenv.env['KICKS_API_KEY'] ?? 'KICKS-9592-717B-B33C-1C7D1C71A299') : 'KICKS-9592-717B-B33C-1C7D1C71A299';

  static String get kicksApiBaseUrl =>
      dotenv.isInitialized ? (dotenv.env['KICKS_API_BASE_URL'] ?? 'https://api.kicks.dev/v3') : 'https://api.kicks.dev/v3';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  static String get mapTileUrl =>
      dotenv.isInitialized
          ? (dotenv.env['MAP_TILE_SERVER_URL'] ?? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png')
          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static String get mapUserAgent =>
      dotenv.isInitialized ? (dotenv.env['MAP_USER_AGENT'] ?? 'com.solestep.app') : 'com.solestep.app';

  static String get firebaseProjectId =>
      dotenv.isInitialized ? (dotenv.env['FIREBASE_PROJECT_ID'] ?? 'toko-fashion-cc521') : 'toko-fashion-cc521';

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
