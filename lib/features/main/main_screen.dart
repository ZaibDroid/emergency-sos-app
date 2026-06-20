import 'package:flutter/material.dart';
import '../../shared/widgets/custom_bottom_nav.dart';
import '../sos/sos_home_screen.dart';
import '../contacts/contacts_screen.dart';
import '../alerts/alerts_screen.dart';
import '../auth/settings_screen.dart';
import 'widgets/user_profile_applet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // We build screens dynamically in the build method to ensure they refresh,
  // except for SosHomeScreen which needs to retain GPS state.

  final List<String> _titles = [
    'Emergency SOS',
    'Trusted Contacts',
    'Alerts',
    'Profile & Settings',
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
        actions: _currentIndex == 0
            ? [
                UserProfileApplet(
                  onTap: () => _onNavTap(3),
                ),
              ]
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const SosHomeScreen(), // Always kept alive for GPS
          _currentIndex == 1 ? const ContactsScreen() : const SizedBox.shrink(),
          _currentIndex == 2 ? const AlertsScreen() : const SizedBox.shrink(),
          _currentIndex == 3 ? const SettingsScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
