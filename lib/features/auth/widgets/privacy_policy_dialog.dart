import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Privacy Policy'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1. Local Data Storage', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('All of your personal data, including your name, phone number, and trusted contacts, are stored strictly on your local device. We do not use any external servers to track or harvest your information.'),
            const SizedBox(height: 16),
            
            Text('2. Location Services', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Your GPS coordinates are only accessed when you explicitly press the SOS button or use the Nearby Services map. We do not track your location in the background.'),
            const SizedBox(height: 16),
            
            Text('3. SMS Communications', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('When an emergency is triggered, the app uses your device\'s native carrier network to send SMS alerts. Standard messaging rates from your provider may apply.'),
            const SizedBox(height: 16),
            
            Text('4. Data Deletion', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('You have full control over your data. Because it is stored locally, uninstalling the app or clearing its storage will permanently delete all your SOS history and contacts.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
