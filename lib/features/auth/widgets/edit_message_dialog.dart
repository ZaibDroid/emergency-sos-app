import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';

class EditMessageDialog extends StatefulWidget {
  const EditMessageDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditMessageDialog(),
    );
  }

  @override
  State<EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<EditMessageDialog> {
  late TextEditingController _msgController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserProvider>();
    _msgController = TextEditingController(text: provider.emergencyMessage);
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final msg = _msgController.text.trim();
    if (msg.isNotEmpty) {
      context.read<UserProvider>().saveEmergencyMessage(msg);
      Fluttertoast.showToast(msg: 'Emergency message saved!');
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency Message'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This message will be sent to your Trusted Contacts via SMS when you press the SOS button.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _msgController,
            labelText: 'Custom Message',
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
