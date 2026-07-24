import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fashion_ecommerce/core/utils/location_helper.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  String? _addressFromCoordinates;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get addressFromCoordinates => _addressFromCoordinates;
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;
  bool get hasLocation => _currentPosition != null;

  /// Ambil lokasi GPS saat ini
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await LocationHelper.getCurrentPosition();
      AppLogger.success(
        'Lokasi: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Gagal mendapatkan lokasi', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set lokasi manual (jika user ingin adjust)
  void setManualLocation(double lat, double lng) {
    _currentPosition = Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    notifyListeners();
  }

  /// Reset lokasi
  void resetLocation() {
    _currentPosition = null;
    _error = null;
    _addressFromCoordinates = null;
    notifyListeners();
  }
}
