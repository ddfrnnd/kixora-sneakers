import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fashion_ecommerce/core/utils/location_helper.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  String? _addressText;

  // Getters
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get addressText => _addressText;
  double? get latitude => _currentPosition?.latitude;
  double? get longitude => _currentPosition?.longitude;
  bool get hasLocation => _currentPosition != null;

  /// Ambil lokasi GPS saat ini & convert ke Alamat Manusia (Reverse Geocoding)
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await LocationHelper.getCurrentPosition();
      AppLogger.success(
        'GPS Coordinates: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
      );

      // Perform Reverse Geocoding to get human-readable address
      await _reverseGeocodePosition(_currentPosition!.latitude, _currentPosition!.longitude);
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Gagal mendapatkan lokasi GPS', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reverse Geocode (Lat/Lng -> Readable Address)
  Future<void> _reverseGeocodePosition(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final street = place.street ?? '';
        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final subAdmin = place.subAdministrativeArea ?? '';
        final postal = place.postalCode ?? '';

        final formattedParts = [street, subLocality, locality, subAdmin, postal]
            .where((p) => p.trim().isNotEmpty)
            .toList();

        _addressText = formattedParts.isNotEmpty
            ? formattedParts.join(', ')
            : 'Lokasi Terdeteksi (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
      }
    } catch (e) {
      _addressText = 'Lokasi Terdeteksi (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    }
  }

  /// Set Alamat Manusia & Geocode ke Koordinat Peta
  Future<void> setAddressAndGeocode(String addressStr, {double? fallbackLat, double? fallbackLng}) async {
    _addressText = addressStr;
    _error = null;

    if (fallbackLat != null && fallbackLng != null) {
      _setCoordinates(fallbackLat, fallbackLng);
      return;
    }

    try {
      final locations = await locationFromAddress(addressStr);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        _setCoordinates(loc.latitude, loc.longitude);
      } else if (fallbackLat != null && fallbackLng != null) {
        _setCoordinates(fallbackLat, fallbackLng);
      }
    } catch (e) {
      // If geocoding fails, fallback gracefully to default city coords or current position
      if (fallbackLat != null && fallbackLng != null) {
        _setCoordinates(fallbackLat, fallbackLng);
      } else if (_currentPosition == null) {
        // Default Jakarta center coords as safe fallback for map display
        _setCoordinates(-6.2088, 106.8456);
      }
    }
  }

  /// Set lokasi manual
  void setManualLocation(double lat, double lng, {String? customAddress}) {
    if (customAddress != null && customAddress.isNotEmpty) {
      _addressText = customAddress;
    }
    _setCoordinates(lat, lng);
  }

  void _setCoordinates(double lat, double lng) {
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
    _addressText = null;
    notifyListeners();
  }
}
