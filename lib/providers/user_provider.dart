import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact_model.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String _userPhone = '';
  String? _userProfileImagePath;
  List<ContactModel> _contacts = [];
  bool _isLoading = true;

  String get userName => _userName;
  String get userPhone => _userPhone;
  String? get userProfileImagePath => _userProfileImagePath;
  List<ContactModel> get contacts => _contacts;
  bool get isLoading => _isLoading;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _userPhone = prefs.getString('userPhone') ?? '';
    _userProfileImagePath = prefs.getString('userProfileImagePath');

    final String? contactsJson = prefs.getString('trusted_contacts');
    if (contactsJson != null && contactsJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(contactsJson);
      _contacts = decoded.map((e) => ContactModel.fromJson(e)).toList();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserProfile({
    required String name,
    required String phone,
    String? imagePath,
  }) async {
    _userName = name;
    _userPhone = phone;
    if (imagePath != null) {
      _userProfileImagePath = imagePath;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userPhone', phone);
    if (imagePath != null) {
      await prefs.setString('userProfileImagePath', imagePath);
    }
    
    notifyListeners();
  }

  Future<void> addContact(ContactModel contact) async {
    if (_contacts.length >= 4) return;
    _contacts.add(contact);
    await _saveContactsToPrefs();
    notifyListeners();
  }

  Future<void> removeContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _saveContactsToPrefs();
    notifyListeners();
  }
  
  Future<void> setContacts(List<ContactModel> newContacts) async {
    _contacts = newContacts;
    await _saveContactsToPrefs();
    notifyListeners();
  }

  Future<void> _saveContactsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedContacts = jsonEncode(
      _contacts.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('trusted_contacts', encodedContacts);
  }
  
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }
}
