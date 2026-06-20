import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';
import '../core/services/sms_service.dart';
import '../core/services/storage_service.dart';

class SosProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final SmsService _smsService = SmsService();
  final StorageService _storageService = StorageService();

  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> triggerSos({Position? currentPosition}) async {
    _isSending = true;
    notifyListeners();

    try {
      // 1. Get Location (Fallback to fresh fetch if stream didn't catch it yet)
      Position position = currentPosition ?? await _locationService.getCurrentPosition();

      // 2. Fetch Data from Storage
      final contacts = await _storageService.getTrustedContacts();
      final customMessage = await _storageService.getEmergencyMessage();

      // 3. Log the outgoing SOS
      await _storageService.logSosEvent(
        latitude: position.latitude,
        longitude: position.longitude,
        contacts: contacts,
      );

      // 4. Send SMS Intent
      await _smsService.sendSosSms(
        contacts: contacts,
        customMessage: customMessage,
        latitude: position.latitude,
        longitude: position.longitude,
      );

    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
