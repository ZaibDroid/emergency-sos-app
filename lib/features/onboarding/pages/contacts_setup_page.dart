import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/contact_model.dart';
import '../../../shared/widgets/contact_card.dart';
import '../../../shared/widgets/custom_button.dart';

class ContactsSetupPage extends StatelessWidget {
  final List<ContactModel> contacts;
  final VoidCallback onAddContact;
  final Function(String) onDeleteContact;
  final VoidCallback onCompleteOnboarding;

  const ContactsSetupPage({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onDeleteContact,
    required this.onCompleteOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.all(24.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 48.h),
          Text('Emergency Contacts', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text(
            'Add up to 4 trusted people who will receive your SOS alerts.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Text(
                      'No contacts added yet.\nPress "Add Contact" to add a contact.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ContactCard(
                        contact: contact,
                        onDelete: () => onDeleteContact(contact.id),
                      );
                    },
                  ),
          ),
          if (contacts.length < 4)
            CustomButton(
              onPressed: onAddContact,
              icon: Icons.person_add,
              label: 'Add Contact',
              isOutlined: true,
            ),
          SizedBox(height: 16.h),
          CustomButton(
            onPressed: onCompleteOnboarding,
            label: 'Finish Setup',
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
