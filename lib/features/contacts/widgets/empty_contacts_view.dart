import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyContactsView extends StatelessWidget {
  const EmptyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contact_phone_outlined,
            size: 64.w,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Trusted Contacts Yet',
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add people you trust to be notified\nduring an emergency.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
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
    );
  }
}
