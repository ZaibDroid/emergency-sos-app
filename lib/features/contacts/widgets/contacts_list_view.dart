import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/contact_model.dart';
import '../../../shared/widgets/contact_card.dart';

class ContactsListView extends StatelessWidget {
  final List<ContactModel> contacts;
  final Function(ContactModel) onEdit;
  final Function(String) onDelete;

  const ContactsListView({
    super.key,
    required this.contacts,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ContactCard(
                contact: contact,
                onEdit: () => onEdit(contact),
                onDelete: () => onDelete(contact.id),
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
                color: contacts.length >= 5 
                    ? theme.colorScheme.error.withValues(alpha: 0.7) 
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  contacts.length >= 5
                      ? 'Maximum limit of 5 contacts reached.'
                      : 'You can add ${5 - contacts.length} more contact${(5 - contacts.length) == 1 ? '' : 's'}.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: contacts.length >= 5 
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
    );
  }
}
