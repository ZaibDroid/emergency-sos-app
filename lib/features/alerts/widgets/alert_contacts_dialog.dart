import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/widgets/initial_avatar.dart';

class AlertContactsDialog extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertContactsDialog({super.key, required this.alert});

  static void show(BuildContext context, Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertContactsDialog(alert: alert),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic>? contacts = alert['contacts'];
    
    // Fallback for older alerts that didn't save the contact list internally
    if (contacts == null || contacts.isEmpty) {
      contacts = context.read<UserProvider>().contacts.map((c) => c.toJson()).toList();
    }

    if (contacts.isEmpty) {
      Fluttertoast.showToast(msg: 'No contact details found.', gravity: ToastGravity.BOTTOM);
      // Need a microtask to pop if building or post-frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
         Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: const Text('Sent to Contacts'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: contacts.map((c) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: InitialAvatar(
              name: c['name'] ?? 'Unknown',
            ),
            title: Text(c['name'] ?? 'Unknown'),
            subtitle: Text(c['phoneNumber'] ?? ''),
          );
        }).toList(),
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
