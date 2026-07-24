/// Custom exceptions untuk aplikasi SoleStep Footwear
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  final String message;

  CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Tidak ada koneksi internet'});

  @override
  String toString() => 'NetworkException: $message';
}

class LocationException implements Exception {
  final String message;

  LocationException({required this.message});

  @override
  String toString() => 'LocationException: $message';
}

class AuthException implements Exception {
  final String message;

  AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}
