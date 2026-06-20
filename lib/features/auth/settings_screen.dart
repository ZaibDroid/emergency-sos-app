import 'package:flutter/material.dart';
import '../../shared/widgets/action_list_tile.dart';
import 'widgets/profile_header.dart';
import 'widgets/edit_profile_dialog.dart';
import 'widgets/edit_message_dialog.dart';
import 'widgets/help_center_dialog.dart';
import 'widgets/privacy_policy_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          ProfileHeader(
            onEditProfile: () => EditProfileDialog.show(context),
          ),
          const SizedBox(height: 32),

          // Settings Options
          Text(
            'Preferences',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ActionListTile(
            icon: Icons.message,
            title: 'Custom Emergency Message',
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () => EditMessageDialog.show(context),
          ),
          const SizedBox(height: 24),
          
          // Support Options
          Text(
            'Support',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ActionListTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () => HelpCenterDialog.show(context),
          ),
          ActionListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () => PrivacyPolicyDialog.show(context),
          ),
        ],
      ),
    );
  }
}
