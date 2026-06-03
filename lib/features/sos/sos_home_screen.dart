import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contact_model.dart';
import '../../shared/widgets/sos_button.dart';

class SosHomeScreen extends StatefulWidget {
  const SosHomeScreen({super.key});

  @override
  State<SosHomeScreen> createState() => _SosHomeScreenState();
}

class _SosHomeScreenState extends State<SosHomeScreen> {
  bool _isLocating = false;
  String _locationStatus = 'Initializing GPS...';
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationStatus = 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationStatus = 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
          () => _locationStatus = 'Location permission permanently denied',
        );
        return;
      }

      // Start listening to location updates
      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter:
                  10, // Update only if moved by 10 meters to save battery
            ),
          ).listen((Position position) {
            if (mounted) {
              setState(() {
                _currentPosition = position;
                _locationStatus =
                    'Ready: ±${position.accuracy.toStringAsFixed(0)}m accuracy';
              });
            }
          });
    } catch (e) {
      debugPrint('Error starting location tracking: $e');
    }
  }

  Future<void> _refreshLocation() async {
    if (_isLocating) return; // Prevent spamming
    setState(() {
      _isLocating = true;
      _locationStatus = 'Fetching fresh GPS coordinates...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationStatus = 'Ready: ±${position.accuracy.toStringAsFixed(0)}m accuracy';
        });
        Fluttertoast.showToast(msg: 'Location manually refreshed!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _locationStatus = 'Error refreshing location');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _triggerSos() async {
    setState(() {
      _isLocating = true;
      if (_currentPosition == null) {
        _locationStatus = 'Fetching GPS coordinates...';
      }
    });

    try {
      Position position;

      // Use the pre-fetched location if available to save time
      if (_currentPosition != null) {
        position = _currentPosition!;
      } else {
        // Fallback to manual fetch if stream hasn't caught a location yet
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception('Location services are disabled.');

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are denied.');
        }

        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      final String mapsLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      setState(() {
        _locationStatus = 'Location acquired!';
      });

      // Fetch Trusted Contacts and Custom Message
      final prefs = await SharedPreferences.getInstance();
      final String? contactsJson = prefs.getString('trusted_contacts');
      final String customMessage =
          prefs.getString('emergencyMessage') ??
          'URGENT: I need help! Here is my exact location:';

      List<ContactModel> contacts = [];
      if (contactsJson != null) {
        final List<dynamic> decoded = jsonDecode(contactsJson);
        contacts = decoded.map((item) => ContactModel.fromJson(item)).toList();
      }

      if (contacts.isEmpty) {
        throw Exception(
          'No trusted contacts found! Please add them in the Contacts tab.',
        );
      }

      // Prepare SMS intent
      final String fullMessage = '$customMessage\n$mapsLink';

      // Clean phone numbers (remove spaces, dashes) and join with a comma
      final String phoneNumbers = contacts
          .map((c) => c.phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''))
          .join(',');

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumbers,
        queryParameters: <String, String>{'body': fullMessage},
      );

      // --- LOG THIS SOS EVENT LOCALLY ---
      final newAlert = {
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'mapsLink': mapsLink,
        'type': 'outgoing',
        'status': 'Sent to ${contacts.length} contact${contacts.length == 1 ? '' : 's'}',
        'contacts': contacts.map((c) => c.toJson()).toList(),
      };
      List<String> history = prefs.getStringList('sos_history') ?? [];
      history.add(jsonEncode(newAlert));
      await prefs.setStringList('sos_history', history);
      // -----------------------------------

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Could not launch SMS app on this device.');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString().replaceAll('Exception: ', ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade800,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationStatus = _currentPosition != null
              ? 'Ready: ±${_currentPosition!.accuracy.toStringAsFixed(0)}m accuracy'
              : 'Detecting Location...';
        });
      }
    }
  }

  Future<void> _dialNumber(String number) async {
    final Uri telUri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not open dialer.');
    }
  }

  void _showNonEmergencyOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Text(
                  'Non-Emergency Contacts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.local_police, size: 24.w),
                title: const Text('Police Helpline'),
                subtitle: const Text('Dial 15'),
                onTap: () {
                  Navigator.pop(context);
                  _dialNumber('15');
                },
              ),
              ListTile(
                leading: Icon(Icons.medical_services, size: 24.w),
                title: const Text('Edhi Ambulance'),
                subtitle: const Text('Dial 115'),
                onTap: () {
                  Navigator.pop(context);
                  _dialNumber('115');
                },
              ),
              ListTile(
                leading: Icon(Icons.car_crash, size: 24.w),
                title: const Text('Motorway Police'),
                subtitle: const Text('Dial 130'),
                onTap: () {
                  Navigator.pop(context);
                  _dialNumber('130');
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasLocationLock = _currentPosition != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SosButton(onTriggered: _isLocating ? () {} : _triggerSos),
            SizedBox(height: 40.h),

            // Status Indicator Card
            InkWell(
              onTap: _isLocating ? null : _refreshLocation,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: hasLocationLock
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: hasLocationLock
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isLocating
                              ? 'PROCESSING...'
                              : (hasLocationLock
                                    ? 'GPS LOCKED'
                                    : 'SEARCHING GPS...'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: hasLocationLock
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                          ),
                        ),
                        if (!_isLocating) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.refresh,
                            size: 16.w,
                            color: hasLocationLock
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                          ),
                        ],
                      ],
                    ),
                  SizedBox(height: 8.h),
                  Text(
                    _locationStatus,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  if (_isLocating && !hasLocationLock)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0.h),
                      child: const LinearProgressIndicator(),
                    )
                  else if (!hasLocationLock)
                    Padding(
                      padding: EdgeInsets.only(top: 8.0.h),
                      child: const LinearProgressIndicator(
                        value: null,
                      ), // Indeterminate for searching
                    ),
                ],
              ),
            ),
            ),
            SizedBox(height: 24.h),

            // Quick Secondary Actions
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _showNonEmergencyOptions,
                    icon: Icon(Icons.phone, size: 24.w),
                    label: const Text('Helplines'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/nearby');
                    },
                    icon: Icon(Icons.local_hospital, size: 24.w),
                    label: const Text('Nearby Services'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
