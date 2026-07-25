import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';

class MapPreviewWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;

  const MapPreviewWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: ValueKey('map-$latitude-$longitude'),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          key: ValueKey('flutter-map-$latitude-$longitude'),
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.solestep.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedPinLocation01,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
