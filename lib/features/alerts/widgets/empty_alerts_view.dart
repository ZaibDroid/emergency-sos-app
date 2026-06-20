import 'package:flutter/material.dart';

class EmptyAlertsView extends StatelessWidget {
  final bool isFiltering;

  const EmptyAlertsView({super.key, required this.isFiltering});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isFiltering) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: theme.colorScheme.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text('No SOS History', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('When you trigger an SOS, it will be logged here.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: theme.colorScheme.surfaceContainerHighest),
          const SizedBox(height: 16),
          Text('No Alerts in Range', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('Try selecting a different date range.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
