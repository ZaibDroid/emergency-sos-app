import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';
import '../core/services/places_service.dart';

class NearbyProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PlacesService _placesService = PlacesService();

  final Completer<GoogleMapController> mapController = Completer();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<dynamic> _placesList = [];
  bool _isLoading = true;

  Position? get currentPosition => _currentPosition;
  Set<Marker> get markers => _markers;
  List<dynamic> get placesList => _placesList;
  bool get isLoading => _isLoading;

  final List<Map<String, dynamic>> categories = [
    {'label': 'Hospitals', 'type': 'hospital', 'icon': Icons.local_hospital},
    {'label': 'Police', 'type': 'police', 'icon': Icons.local_police},
    {'label': 'Mechanics', 'type': 'car_repair', 'icon': Icons.car_repair},
    {'label': 'Petrol Pumps', 'type': 'gas_station', 'icon': Icons.local_gas_station},
    {'label': 'Restaurants', 'type': 'restaurant', 'icon': Icons.restaurant},
  ];
  
  String _selectedCategoryType = 'hospital';
  String get selectedCategoryType => _selectedCategoryType;

  NearbyProvider() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      Position position = await _locationService.getCurrentPosition();
      _currentPosition = position;
      notifyListeners();

      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ));

      await fetchPlaces();
    } catch (e) {
      // Error getting location
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlaces() async {
    if (_currentPosition == null) return;
    
    _isLoading = true;
    notifyListeners();

    final elements = await _placesService.fetchNearbyPlaces(
      _currentPosition!.latitude, 
      _currentPosition!.longitude, 
      _selectedCategoryType
    );

    Set<Marker> newMarkers = {};
    
    // Add marker for current user location
    newMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'You are here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      )
    );

    for (var place in elements) {
      double? lat;
      double? lon;

      if (place['type'] == 'node') {
        lat = (place['lat'] as num?)?.toDouble();
        lon = (place['lon'] as num?)?.toDouble();
      } else if (place['center'] != null) {
        lat = (place['center']['lat'] as num?)?.toDouble();
        lon = (place['center']['lon'] as num?)?.toDouble();
      }

      if (lat == null || lon == null) continue;
      
      final tags = place['tags'] ?? {};
      final name = tags['name'] ?? 'Unnamed Service';
      final address = tags['addr:full'] ?? tags['addr:street'] ?? 'Address not available';
      
      newMarkers.add(
        Marker(
          markerId: MarkerId(place['id'].toString()),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: name, snippet: address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        )
      );
    }

    _placesList = elements;
    _markers = newMarkers;
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String type) {
    if (_selectedCategoryType == type) return;
    _selectedCategoryType = type;
    _placesList = []; // clear previous list while loading
    notifyListeners();
    fetchPlaces();
  }

  void handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    int currentIndex = categories.indexWhere((c) => c['type'] == _selectedCategoryType);
    
    // Swipe Left (Next)
    if (details.primaryVelocity! < -300) {
      if (currentIndex < categories.length - 1) {
        selectCategory(categories[currentIndex + 1]['type']);
      }
    } 
    // Swipe Right (Previous)
    else if (details.primaryVelocity! > 300) {
      if (currentIndex > 0) {
        selectCategory(categories[currentIndex - 1]['type']);
      }
    }
  }

  void moveToLocation(double lat, double lon) async {
    final controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(lat, lon),
      16.0
    ));
  }
}
