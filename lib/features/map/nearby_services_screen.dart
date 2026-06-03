import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<dynamic> _placesList = [];
  bool _isLoading = true;

  // Filter Categories
  final List<Map<String, dynamic>> _categories = [
    {'label': 'Hospitals', 'type': 'hospital', 'icon': Icons.local_hospital},
    {'label': 'Police', 'type': 'police', 'icon': Icons.local_police},
    {'label': 'Mechanics', 'type': 'car_repair', 'icon': Icons.car_repair},
    {'label': 'Petrol Pumps', 'type': 'gas_station', 'icon': Icons.local_gas_station},
    {'label': 'Restaurants', 'type': 'restaurant', 'icon': Icons.restaurant},
  ];
  
  String _selectedCategoryType = 'hospital'; // Default


  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        _currentPosition = position;
      });

      // Move camera to user
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.0,
        ),
      ));

      // Fetch places for default category
      await _fetchNearbyPlaces();

    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;
    int currentIndex = _categories.indexWhere((c) => c['type'] == _selectedCategoryType);
    
    // Swipe Left (Next)
    if (details.primaryVelocity! < -300) {
      if (currentIndex < _categories.length - 1) {
        _onCategorySelected(_categories[currentIndex + 1]['type']);
      }
    } 
    // Swipe Right (Previous)
    else if (details.primaryVelocity! > 300) {
      if (currentIndex > 0) {
        _onCategorySelected(_categories[currentIndex - 1]['type']);
      }
    }
  }

  String _buildOverpassQuery(double lat, double lng, String type) {
    String queryBody = '';
    
    if (type == 'hospital') {
      queryBody = 'nwr["amenity"~"hospital|clinic|doctors"](around:10000, $lat, $lng);';
    } else if (type == 'police') {
      queryBody = 'nwr["amenity"="police"](around:10000, $lat, $lng);';
    } else if (type == 'car_repair') {
      queryBody = 'nwr["shop"~"car_repair|motorcycle_repair"](around:10000, $lat, $lng);';
    } else if (type == 'gas_station') {
      queryBody = 'nwr["amenity"="fuel"](around:10000, $lat, $lng);';
    } else if (type == 'restaurant') {
      queryBody = 'nwr["amenity"~"restaurant|fast_food|cafe|food_court"](around:10000, $lat, $lng);';
    }
    
    // Use timeout:25 to give the server more time, but keep radius at 5000m to prevent crashes
    return '''
      [out:json][timeout:25];
      (
        $queryBody
      );
      out center;
    ''';
  }

  Future<void> _fetchNearbyPlaces() async {
    if (_currentPosition == null) return;
    
    setState(() => _isLoading = true);

    final String url = 'https://overpass-api.de/api/interpreter';
    final String query = _buildOverpassQuery(
      _currentPosition!.latitude, 
      _currentPosition!.longitude, 
      _selectedCategoryType
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        body: query,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'User-Agent': 'EmergencySOSApp/1.0 (StudentProject)',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        
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

        // Add markers for places
        for (var place in elements) {
          double? lat;
          double? lon;

          // OSM uses 'lat' and 'lon' at the root for nodes, and inside 'center' for ways/relations
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

        if (mounted) {
          setState(() {
            _placesList = elements;
            _markers = newMarkers;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Overpass API Error: ${response.statusCode}');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('HTTP Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String type) {
    if (_selectedCategoryType == type) return;
    setState(() {
      _selectedCategoryType = type;
      _placesList = []; // clear previous list while loading
    });
    _fetchNearbyPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Services'), centerTitle: true),
      body: GestureDetector(
        onHorizontalDragEnd: _onSwipe,
        child: Column(
          children: [
          // Google Map Area
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                  },
                ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategoryType == category['type'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(category['label']),
                    avatar: Icon(
                      category['icon'],
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (bool selected) {
                      if (selected) {
                        _onCategorySelected(category['type']);
                      }
                    },
                    backgroundColor: theme.colorScheme.surface,
                    selectedColor: theme.colorScheme.secondaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Results List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _placesList.isEmpty
                ? Center(
                    child: Text(
                      'No places found nearby.',
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _placesList.length,
                    itemBuilder: (context, index) {
                      final place = _placesList[index];
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

                      // Calculate straight line distance
                      double distanceInMeters = Geolocator.distanceBetween(
                        _currentPosition!.latitude, 
                        _currentPosition!.longitude, 
                        lat, 
                        lon
                      );
                      
                      String distanceText = distanceInMeters < 1000 
                        ? '${distanceInMeters.toStringAsFixed(0)} m away' 
                        : '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';

                      IconData listIcon = Icons.place;
                      if (_selectedCategoryType == 'hospital') listIcon = Icons.local_hospital;
                      if (_selectedCategoryType == 'police') listIcon = Icons.local_police;
                      if (_selectedCategoryType == 'car_repair') listIcon = Icons.car_repair;
                      if (_selectedCategoryType == 'gas_station') listIcon = Icons.local_gas_station;
                      if (_selectedCategoryType == 'restaurant') listIcon = Icons.restaurant;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            listIcon,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            name,
                            style: theme.textTheme.labelLarge,
                          ),
                          subtitle: Text(
                            '$distanceText\n$address',
                            style: theme.textTheme.bodyMedium,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.directions),
                          onTap: () {
                            // Move map to this location
                            _mapController.future.then((controller) {
                              controller.animateCamera(CameraUpdate.newLatLngZoom(
                                LatLng(lat, lon),
                                16.0
                              ));
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
