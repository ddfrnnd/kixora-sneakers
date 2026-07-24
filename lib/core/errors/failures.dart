/// Failure classes untuk error handling
abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Tidak ada koneksi internet'});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
