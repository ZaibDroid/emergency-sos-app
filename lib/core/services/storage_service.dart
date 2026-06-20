import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/contact_model.dart';

class StorageService {
  Future<List<ContactModel>> getTrustedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('trusted_contacts');
    
    if (contactsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(contactsJson);
    return decoded.map((item) => ContactModel.fromJson(item)).toList();
  }

  Future<String> getEmergencyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('emergencyMessage') ??
        'URGENT: I need help! Here is my exact location:';
  }

  Future<void> logSosEvent({
    required double latitude,
    required double longitude,
    required List<ContactModel> contacts,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
    
    final newAlert = {
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'mapsLink': mapsLink,
      'type': 'outgoing',
      'status': 'Sent to ${contacts.length} contact${contacts.length == 1 ? '' : 's'}',
      'contacts': contacts.map((c) => c.toJson()).toList(),
    };
    
    List<String> history = prefs.getStringList('sos_history') ?? [];
    history.add(jsonEncode(newAlert));
    await prefs.setStringList('sos_history', history);
  }

  Future<List<Map<String, dynamic>>> getSosHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyStrings = prefs.getStringList('sos_history');
    
    if (historyStrings == null) return [];
    
    final history = historyStrings.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    // Reverse so newest is at the top
    return history.reversed.toList();
  }

  Future<void> deleteSosEvent(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyStrings = prefs.getStringList('sos_history');
    
    if (historyStrings == null) return;
    
    final history = historyStrings.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    history.removeWhere((alert) => alert['timestamp'] == timestamp);
    
    final listToSave = history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('sos_history', listToSave);
  }

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboardingCompleted') ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }
}
