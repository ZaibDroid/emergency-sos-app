import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_empty_state.dart';

class EmptyContactsView extends StatelessWidget {
  const EmptyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomEmptyState(
      icon: Icons.contact_phone_outlined,
      title: 'No Trusted Contacts Yet',
      subtitle: 'Add people you trust to be notified\nduring an emergency.',
      extraContent: Text(
        'You can add up to 5 contacts',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
