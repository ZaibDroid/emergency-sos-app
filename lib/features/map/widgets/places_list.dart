import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/widgets/custom_empty_state.dart';

class PlacesList extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> places;
  final Position? currentPosition;
  final String selectedCategory;
  final Function(double, double) onPlaceTap;

  const PlacesList({
    super.key,
    required this.isLoading,
    required this.places,
    required this.currentPosition,
    required this.selectedCategory,
    required this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (places.isEmpty) {
      return const CustomEmptyState(
        icon: Icons.search_off,
        title: 'No places found',
        subtitle: 'We couldn\'t find any services nearby.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        final tags = place['tags'] ?? {};
        final name = tags['name'] ?? 'Unnamed Service';
        final address = tags['addr:full'] ?? tags['addr:street'] ?? 'Address not available';
        
        double lat = 0.0;
        double lon = 0.0;
        if (place['type'] == 'node') {
          lat = (place['lat'] as num?)?.toDouble() ?? 0.0;
          lon = (place['lon'] as num?)?.toDouble() ?? 0.0;
        } else if (place['center'] != null) {
          lat = (place['center']['lat'] as num?)?.toDouble() ?? 0.0;
          lon = (place['center']['lon'] as num?)?.toDouble() ?? 0.0;
        }

        double distanceInMeters = 0.0;
        if (currentPosition != null) {
          distanceInMeters = Geolocator.distanceBetween(
            currentPosition!.latitude, 
            currentPosition!.longitude, 
            lat, 
            lon
          );
        }
        
        String distanceText = distanceInMeters < 1000 
          ? '${distanceInMeters.toStringAsFixed(0)} m away' 
          : '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';

        IconData listIcon = Icons.place;
        if (selectedCategory == 'hospital') listIcon = Icons.local_hospital;
        if (selectedCategory == 'police') listIcon = Icons.local_police;
        if (selectedCategory == 'car_repair') listIcon = Icons.car_repair;
        if (selectedCategory == 'gas_station') listIcon = Icons.local_gas_station;
        if (selectedCategory == 'restaurant') listIcon = Icons.restaurant;

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: Icon(listIcon, color: theme.colorScheme.primary),
            title: Text(name, style: theme.textTheme.labelLarge),
            subtitle: Text('$distanceText\n$address', style: theme.textTheme.bodyMedium),
            isThreeLine: true,
            trailing: const Icon(Icons.directions),
            onTap: () => onPlaceTap(lat, lon),
          ),
        );
      },
    );
  }
}
