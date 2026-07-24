class AppConstants {
  AppConstants._();

  static const String appName = 'SoleStep Footwear';
  static const int connectionTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int cacheDuration = 3600;

  // SharedPreferences keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyLastSync = 'last_sync_time';

  // Secure storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyAdminEmail = 'admin_email';

  // Order status
  static const String statusBaru = 'Baru';
  static const String statusDiproses = 'Diproses';
  static const String statusSelesai = 'Selesai';

  // Product categories for shoes
  static const String categorySneakers = 'Sneakers';
  static const String categoryRunning = 'Running';
  static const String categoryCasual = 'Casual';
  static const String categoryFormal = 'Formal';
  static const List<String> categories = [
    categorySneakers,
    categoryRunning,
    categoryCasual,
    categoryFormal,
  ];
}
