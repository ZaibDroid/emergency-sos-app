import 'package:flutter/material.dart';

class HelpCenterDialog extends StatelessWidget {
  const HelpCenterDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpCenterDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Help Center'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SOS Button', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Long-press the SOS button on the Home Screen to immediately send your GPS location and custom emergency message to your contacts.'),
            const SizedBox(height: 16),
            
            Text('Trusted Contacts', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Navigate to the Contacts tab to add up to 5 people. These are the individuals who will receive your SMS distress signals.'),
            const SizedBox(height: 16),
            
            Text('Alerts History', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('The Alerts tab keeps a secure, local log of every time you trigger an SOS, allowing you to filter by date and review past emergencies.'),
            const SizedBox(height: 16),
            
            Text('Nearby Services', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Use the Map tab to instantly locate critical services like Police Stations and Hospitals within a 10km radius.'),
            const SizedBox(height: 24),
            
            const Text('Need further assistance? Contact us at support@emergencysos.com', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
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
