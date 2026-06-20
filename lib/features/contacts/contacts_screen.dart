import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/user_provider.dart';
import '../../models/contact_model.dart';
import '../../shared/widgets/contact_form_dialog.dart';
import 'widgets/empty_contacts_view.dart';
import 'widgets/contacts_list_view.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  void _showDeleteDialog(BuildContext context, UserProvider provider, String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to remove this trusted contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeContact(id);
              Navigator.pop(dialogContext);
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

  void _showContactDialog(BuildContext context, UserProvider provider, {ContactModel? contactToEdit}) {
    if (contactToEdit == null && provider.contacts.length >= 5) {
      Fluttertoast.showToast(
        msg: 'You can only have a maximum of 5 Trusted Contacts.',
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    ContactFormDialog.show(
      context,
      contactToEdit: contactToEdit,
      onSave: (contact) {
        if (contactToEdit != null) {
          provider.updateContact(contact);
          Fluttertoast.showToast(msg: 'Contact updated!', gravity: ToastGravity.BOTTOM);
        } else {
          provider.addContact(contact);
          Fluttertoast.showToast(msg: 'Contact added!', gravity: ToastGravity.BOTTOM);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.contacts.isEmpty) {
              return const EmptyContactsView();
            }

            return ContactsListView(
              contacts: provider.contacts,
              onEdit: (contact) => _showContactDialog(context, provider, contactToEdit: contact),
              onDelete: (id) => _showDeleteDialog(context, provider, id),
            );
          },
        ),
      ),
      floatingActionButton: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.contacts.length >= 5) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () => _showContactDialog(context, provider),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Contact'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          );
        },
      ),
    );
  }
}
