import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/widgets/action_list_tile.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _userName = 'User';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
      _profileImagePath = prefs.getString('userProfileImagePath');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : null,
                  child: _profileImagePath == null
                      ? Icon(
                          Icons.shield,
                          color: theme.colorScheme.onPrimary,
                          size: 32.w,
                        )
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    _userName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ActionListTile(
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ActionListTile(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
