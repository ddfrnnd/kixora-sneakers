import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/profile/data/models/address_item.dart';
import 'package:fashion_ecommerce/features/profile/data/repositories/address_repository.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Rumah');
  final TextEditingController _addressController = TextEditingController();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'User-Agent': 'SoleStepFootwear/1.0 (Mobile Fashion App)'},
    ),
  );

  Timer? _debounceTimer;

  // Initial center default (Semarang / User position)
  LatLng _currentLatLng = const LatLng(-6.9932, 110.4203);
  bool _isDefault = false;
  bool _isLocatingGPS = false;
  bool _isGeocoding = false;
  bool _showSearchResults = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedStreetName = 'Mendeteksi lokasi HP...';
  String _selectedDistrict = 'Geser peta untuk menetapkan titik pas';

  @override
  void initState() {
    super.initState();
    _fetchCurrentGPSLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Detect REAL Device GPS location with robust error handling and map re-centering
  Future<void> _fetchCurrentGPSLocation() async {
    if (!mounted) return;
    setState(() {
      _isLocatingGPS = true;
      _selectedStreetName = 'Mendeteksi GPS HP...';
      _selectedDistrict = 'Mengambil posisi presisi...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Izin lokasi ditolak. Mohon aktifkan izin lokasi di Pengaturan HP.'),
            backgroundColor: AppColors.error,
          ),
        );
      }

      // 1. Try last known position first for instant non-blocking response
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        _currentLatLng = LatLng(lastKnown.latitude, lastKnown.longitude);
        _mapController.move(_currentLatLng, 17.0);
        _reverseGeocode(_currentLatLng);
      }

      // 2. Fetch high accuracy position with strict 4s timeout so it NEVER hangs
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 4),
        ),
      ).timeout(
        const Duration(seconds: 4),
        onTimeout: () async {
          Position? fallbackPos = await Geolocator.getLastKnownPosition();
          if (fallbackPos != null) return fallbackPos;
          return Position(
            longitude: _currentLatLng.longitude,
            latitude: _currentLatLng.latitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        },
      );

      if (mounted) {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentLatLng, 17.0);
        await _reverseGeocode(_currentLatLng);
      }
    } catch (_) {
      if (mounted) {
        await _reverseGeocode(_currentLatLng);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocatingGPS = false;
        });
      }
    }
  }

  /// Real Reverse Geocoding via OpenStreetMap Nominatim API
  Future<void> _reverseGeocode(LatLng target) async {
    setState(() {
      _isGeocoding = true;
    });

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': target.latitude,
          'lon': target.longitude,
          'addressdetails': 1,
          'accept-language': 'id',
        },
      );

      if (response.data is Map) {
        final Map data = response.data;
        final String displayName = (data['display_name'] ?? '').toString();
        final List<String> displayParts = displayName.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        final Map addressMap = (data['address'] is Map) ? data['address'] : {};

        final String road = (addressMap['road'] ??
            addressMap['pedestrian'] ??
            addressMap['footway'] ??
            addressMap['residential'] ??
            addressMap['suburb'] ??
            addressMap['neighbourhood'] ??
            addressMap['village'] ??
            addressMap['town'] ??
            addressMap['city_district'] ??
            addressMap['city'] ??
            (displayParts.isNotEmpty ? displayParts.first : 'Titik Lokasi Terpilih')).toString();

        final String houseNum = (addressMap['house_number'] ?? addressMap['building'] ?? '').toString();
        final String suburb = (addressMap['suburb'] ?? addressMap['village'] ?? addressMap['neighbourhood'] ?? addressMap['quarter'] ?? '').toString();
        final String city = (addressMap['city'] ?? addressMap['city_district'] ?? addressMap['town'] ?? addressMap['county'] ?? addressMap['municipality'] ?? '').toString();
        final String state = (addressMap['state'] ?? addressMap['region'] ?? '').toString();
        final String postcode = (addressMap['postcode'] ?? '').toString();

        final String streetPart = houseNum.isNotEmpty ? '$road No. $houseNum' : road;
        final String districtPart = [suburb, city, state, postcode]
            .where((s) => s.toString().trim().isNotEmpty && s != road)
            .join(', ');

        final String fullAddressText = displayName.isNotEmpty ? displayName : '$streetPart, $districtPart';

        if (mounted) {
          setState(() {
            _selectedStreetName = streetPart;
            _selectedDistrict = districtPart.isNotEmpty ? districtPart : streetPart;
            _addressController.text = fullAddressText;

            if (_nameController.text.isEmpty || _nameController.text == 'Rumah' || _nameController.text.startsWith('Alamat')) {
              if (suburb.isNotEmpty) {
                _nameController.text = 'Alamat $suburb';
              } else if (city.isNotEmpty) {
                _nameController.text = 'Alamat $city';
              }
            }
          });
        }
      } else {
        _fallbackAddress(target);
      }
    } catch (_) {
      _fallbackAddress(target);
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  void _fallbackAddress(LatLng target) {
    if (mounted) {
      final latStr = target.latitude.toStringAsFixed(4);
      final lonStr = target.longitude.toStringAsFixed(4);
      setState(() {
        _selectedStreetName = 'Koordinat GPS ($latStr, $lonStr)';
        _selectedDistrict = 'Lokasi Terpilih Perangkat';
        _addressController.text = 'Lokasi GPS Perangkat ($latStr, $lonStr)';
      });
    }
  }

  /// Real Location Search via OpenStreetMap Nominatim Search API
  void _onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() {
        _showSearchResults = true;
      });

      try {
        final response = await _dio.get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {
            'format': 'json',
            'q': query,
            'limit': 6,
            'addressdetails': 1,
            'countrycodes': 'id',
            'accept-language': 'id',
          },
        );

        if (response.data is List) {
          final List items = response.data;
          final List<Map<String, dynamic>> mapped = items.map((item) {
            final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0;
            final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0;
            return {
              'title': item['name'] ?? item['display_name']?.toString().split(',').first ?? query,
              'address': item['display_name'] ?? query,
              'latLng': LatLng(lat, lon),
            };
          }).toList();

          if (mounted) {
            setState(() {
              _searchResults = mapped;
            });
          }
        }
      } catch (_) {
        // Silently handle search errors
      }
    });
  }

  void _selectSearchResult(Map<String, dynamic> location) {
    final LatLng target = location['latLng'];
    setState(() {
      _showSearchResults = false;
      _searchController.text = location['title'];
      _currentLatLng = target;
    });

    FocusScope.of(context).unfocus();
    _mapController.move(target, 17.5);
    _reverseGeocode(target);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📍 Peta disesuaikan ke: ${location['title']}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveAddress() async {
    final name = _nameController.text.trim();
    final addressText = _addressController.text.trim();

    if (name.isEmpty || addressText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama alamat dan detail alamat lengkap.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final newAddress = AddressItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      fullAddress: addressText,
      latitude: _currentLatLng.latitude,
      longitude: _currentLatLng.longitude,
      isDefault: _isDefault,
    );

    await AddressRepository().saveAddress(newAddress);

    if (!mounted) return;
    context.pop(newAddress);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.48;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Stack(
        children: [
          // 1. Real OpenStreetMap Interactive FlutterMap Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: mapHeight,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLatLng,
                    initialZoom: 16.5,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        setState(() {
                          _currentLatLng = position.center;
                        });
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 250), () {
                          _reverseGeocode(_currentLatLng);
                        });
                      }
                    },
                    onTap: (tapPosition, point) {
                      setState(() {
                        _currentLatLng = point;
                      });
                      _mapController.move(point, 17.0);
                      _reverseGeocode(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.solestep.fashion_ecommerce',
                    ),
                  ],
                ),

                // Gojek-style FIXED Center Pin Marker with Callout Pill Badge
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic Address Callout Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isGeocoding
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const HugeIcon(
                                      icon: HugeIcons.strokeRoundedLocation01,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 160),
                                    child: Text(
                                      _selectedStreetName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 160),
                                    child: Text(
                                      _selectedDistrict,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Center Pin Target Icon
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hint Banner on Map
                Positioned(
                  left: 16,
                  right: 76,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Geser peta agar titik pas di depan rumah Anda',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating GPS Re-center Button
          Positioned(
            right: 16,
            bottom: (screenHeight * 0.54) + 16,
            child: FloatingActionButton(
              heroTag: 're_center_gps_gojek',
              onPressed: _isLocatingGPS ? null : _fetchCurrentGPSLocation,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              child: _isLocatingGPS
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : const HugeIcon(
                      icon: HugeIcons.strokeRoundedGps01,
                      color: AppColors.primary,
                      size: 24,
                    ),
            ),
          ),

          // 2. Top Header Bar & Real Search Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () => context.pop(),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedArrowLeft01,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Search Bar (Cari Alamat Real via OpenStreetMap API)
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchQueryChanged,
                              onTap: () {
                                if (_searchResults.isNotEmpty) {
                                  setState(() {
                                    _showSearchResults = true;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Cari jalan, kelurahan, atau kota...',
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 38,
                                  minHeight: 38,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 6),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchQueryChanged('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real Search Results Overlay List
                  if (_showSearchResults && _searchResults.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final loc = _searchResults[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFF0F0F0),
                              radius: 18,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedLocation01,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              loc['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              loc['address'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(loc),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Address Details Form Bottom Sheet (Stitch UI)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: screenHeight * 0.54,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Address Details',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input 1: Name Address
                    Text(
                      'Name Address',
                      style: AppTextStyles.h3.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'Enter name (e.g. Rumah, Kantor, Apartemen)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input 2: Address Details (Real-time Reverse Geocoded from Center Map Pin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Address Details',
                          style: AppTextStyles.h3.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (_isGeocoding) ...[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _addressController,
                        maxLines: 2,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Geser titik peta atau cari alamat di atas...',
                          border: InputBorder.none,
                          suffixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Checkbox: Make default address
                    Row(
                      children: [
                        Checkbox(
                          value: _isDefault,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _isDefault = val ?? false;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDefault = !_isDefault;
                              });
                            },
                            child: Text(
                              'Make this as the default address',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Button: Add
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
