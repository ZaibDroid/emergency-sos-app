import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  bool _isLocating = false;
  String _locationStatus = 'Initializing GPS...';
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool get isLocating => _isLocating;
  String get locationStatus => _locationStatus;
  Position? get currentPosition => _currentPosition;
  bool get hasLocationLock => _currentPosition != null;

  LocationProvider() {
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      await _locationService.checkAndRequestPermissions();
      
      _positionStreamSubscription = _locationService.getPositionStream()
          .listen((Position position) {
        _currentPosition = position;
        _locationStatus = 'Ready: ±${position.accuracy.toStringAsFixed(0)}m accuracy';
        notifyListeners();
      });
    } catch (e) {
      _locationStatus = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    if (_isLocating) return;
    
    _isLocating = true;
    _locationStatus = 'Fetching fresh GPS coordinates...';
    notifyListeners();

    try {
      Position position = await _locationService.getCurrentPosition();
      _currentPosition = position;
      _locationStatus = 'Ready: ±${position.accuracy.toStringAsFixed(0)}m accuracy';
      Fluttertoast.showToast(msg: 'Location manually refreshed!');
    } catch (e) {
      _locationStatus = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }
}
