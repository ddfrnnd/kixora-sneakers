import 'package:geolocator/geolocator.dart';
import 'package:fashion_ecommerce/core/errors/exceptions.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

class LocationHelper {
  LocationHelper._();

  /// Cek apakah GPS service aktif dan permission diberikan
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(message: 'GPS tidak aktif. Mohon aktifkan GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(message: 'Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
        message: 'Izin lokasi ditolak permanen. Silakan aktifkan di pengaturan.',
      );
    }

    return true;
  }

  /// Ambil koordinat GPS saat ini
  static Future<Position> getCurrentPosition() async {
    await checkPermission();

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      AppLogger.info(
        'GPS: lat=${position.latitude}, lng=${position.longitude}',
      );

      return position;
    } catch (e) {
      AppLogger.error('Gagal mendapatkan lokasi', e);
      throw LocationException(
        message: 'Gagal mendapatkan lokasi. Coba lagi.',
      );
    }
  }

  /// Hitung jarak antara dua koordinat (dalam meter)
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
