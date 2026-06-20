import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/contact_model.dart';
import 'custom_text_field.dart';

class ContactFormDialog extends StatefulWidget {
  final ContactModel? contactToEdit;
  final Function(ContactModel) onSave;

  const ContactFormDialog({super.key, this.contactToEdit, required this.onSave});

  static void show(BuildContext context, {ContactModel? contactToEdit, required Function(ContactModel) onSave}) {
    showDialog(
      context: context,
      builder: (context) => ContactFormDialog(contactToEdit: contactToEdit, onSave: onSave),
    );
  }

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contactToEdit?.name ?? '');
    _phoneController = TextEditingController(text: widget.contactToEdit?.phoneNumber ?? '');
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

    if (name.isEmpty || phone.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter both name and phone number');
      return;
    }

    widget.onSave(
      ContactModel(
        id: widget.contactToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phoneNumber: phone,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contactToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Contact' : 'Add Emergency Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: 'Name',
            prefixIcon: Icons.person,
            textCapitalization: TextCapitalization.words,
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
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
