import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [INFO] $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [ERROR] $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   StackTrace: $stackTrace');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ [WARNING] $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ [SUCCESS] $message');
    }
  }
}
