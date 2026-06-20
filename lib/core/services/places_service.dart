import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PlacesService {
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
    
    return '''
      [out:json][timeout:25];
      (
        $queryBody
      );
      out center;
    ''';
  }

  Future<List<dynamic>> fetchNearbyPlaces(double lat, double lng, String type) async {
    const String url = 'https://overpass-api.de/api/interpreter';
    final String query = _buildOverpassQuery(lat, lng, type);

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
        return data['elements'] as List;
      } else {
        debugPrint('Overpass API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('HTTP Error: $e');
      return [];
    }
  }
}
