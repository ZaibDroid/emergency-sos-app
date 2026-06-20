import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyMap extends StatelessWidget {
  final bool isLoading;
  final double? lat;
  final double? lon;
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;

  const NearbyMap({
    super.key,
    required this.isLoading,
    required this.lat,
    required this.lon,
    required this.markers,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 250.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: (lat == null || lon == null)
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat!, lon!),
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              onMapCreated: onMapCreated,
            ),
    );
  }
}
