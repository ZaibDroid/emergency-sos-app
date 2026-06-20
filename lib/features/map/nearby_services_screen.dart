import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/nearby_provider.dart';
import 'widgets/nearby_map.dart';
import 'widgets/category_filters.dart';
import 'widgets/places_list.dart';

class NearbyServicesScreen extends StatelessWidget {
  const NearbyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NearbyProvider(),
      child: const _NearbyServicesView(),
    );
  }
}

class _NearbyServicesView extends StatelessWidget {
  const _NearbyServicesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Services'), centerTitle: true),
      body: Consumer<NearbyProvider>(
        builder: (context, provider, child) {
          return GestureDetector(
            onHorizontalDragEnd: provider.handleSwipe,
            child: Column(
              children: [
                NearbyMap(
                  isLoading: provider.isLoading,
                  lat: provider.currentPosition?.latitude,
                  lon: provider.currentPosition?.longitude,
                  markers: provider.markers,
                  onMapCreated: (controller) => provider.mapController.complete(controller),
                ),
                CategoryFilters(
                  categories: provider.categories,
                  selectedCategory: provider.selectedCategoryType,
                  onCategorySelected: provider.selectCategory,
                ),
                Expanded(
                  child: PlacesList(
                    isLoading: provider.isLoading,
                    places: provider.placesList,
                    currentPosition: provider.currentPosition,
                    selectedCategory: provider.selectedCategoryType,
                    onPlaceTap: provider.moveToLocation,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
