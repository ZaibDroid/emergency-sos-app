import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/contact_model.dart';
import '../../shared/widgets/contact_card.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<ContactModel> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('trusted_contacts');

    if (contactsJson != null) {
      final List<dynamic> decoded = jsonDecode(contactsJson);
      setState(() {
        _contacts = decoded.map((item) => ContactModel.fromJson(item)).toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _contacts.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('trusted_contacts', encoded);
  }

  void _showContactDialog({ContactModel? contactToEdit}) {
    if (contactToEdit == null && _contacts.length >= 5) {
      Fluttertoast.showToast(
        msg: 'You can only have a maximum of 5 Trusted Contacts.',
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    final isEditing = contactToEdit != null;
    final nameController = TextEditingController(
      text: contactToEdit?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: contactToEdit?.phoneNumber ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Contact' : 'Add Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  Fluttertoast.showToast(
                    msg: 'Please enter both name and phone number',
                  );
                  return;
                }

                setState(() {
                  if (isEditing) {
                    final index = _contacts.indexWhere(
                      (c) => c.id == contactToEdit.id,
                    );
                    if (index != -1) {
                      _contacts[index] = ContactModel(
                        id: contactToEdit.id,
                        name: name,
                        phoneNumber: phone,
                      );
                    }
                  } else {
                    _contacts.add(
                      ContactModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        phoneNumber: phone,
                      ),
                    );
                  }
                });

                await _saveContacts();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                Fluttertoast.showToast(
                  msg: isEditing ? 'Contact updated!' : 'Contact added!',
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteContact(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text(
          'Are you sure you want to remove this trusted contact?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _contacts.removeWhere((c) => c.id == id);
              });
              await _saveContacts();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              Fluttertoast.showToast(msg: 'Contact removed');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _contacts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.contact_phone_outlined,
                      size: 64.w,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No Trusted Contacts Yet',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add people you trust to be notified\nduring an emergency.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'You can add up to 5 contacts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return ContactCard(
                          contact: contact,
                          onEdit: () => _showContactDialog(contactToEdit: contact),
                          onDelete: () => _deleteContact(contact.id),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 84.0.h, // Extra padding so FAB doesn't cover it
                      left: 16.w,
                      right: 16.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.w,
                          color: _contacts.length >= 5 
                              ? theme.colorScheme.error.withValues(alpha: 0.7) 
                              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            _contacts.length >= 5
                                ? 'Maximum limit of 5 contacts reached.'
                                : 'You can add ${5 - _contacts.length} more contact${(5 - _contacts.length) == 1 ? '' : 's'}.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _contacts.length >= 5 
                                  ? theme.colorScheme.error.withValues(alpha: 0.7) 
                                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: _contacts.length < 5
          ? FloatingActionButton.extended(
              onPressed: () => _showContactDialog(),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Contact'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            )
          : null,
    );
  }
}
