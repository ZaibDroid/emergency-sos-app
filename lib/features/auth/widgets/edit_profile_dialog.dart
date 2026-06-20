import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditProfileDialog(),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<UserProvider>();
    _nameController = TextEditingController(text: provider.userName);
    _phoneController = TextEditingController(text: provider.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isNotEmpty) {
      context.read<UserProvider>().saveUserProfile(
        name: name,
        phone: phone,
        imagePath: context.read<UserProvider>().userProfileImagePath,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            labelText: 'Phone Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
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
