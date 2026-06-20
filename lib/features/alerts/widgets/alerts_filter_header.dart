import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/alerts_provider.dart';
import '../../../shared/widgets/date_filter_button.dart';

class AlertsFilterHeader extends StatelessWidget {
  const AlertsFilterHeader({super.key});

  Future<void> _pickStartDate(BuildContext context, AlertsProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      provider.setStartDate(picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context, AlertsProvider provider) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      provider.setEndDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AlertsProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerLowest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Date',
                    style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  if (provider.startDate != null || provider.endDate != null)
                    TextButton.icon(
                      onPressed: provider.clearDates,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear Filter'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  DateFilterButton(
                    onPressed: () => _pickStartDate(context, provider),
                    date: provider.startDate,
                    label: 'Start Date',
                  ),
                  const SizedBox(width: 12),
                  DateFilterButton(
                    onPressed: () => _pickEndDate(context, provider),
                    date: provider.endDate,
                    label: 'End Date',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.filteredHistory.length} Alerts Found',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}
