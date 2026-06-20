import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_empty_state.dart';

class EmptyAlertsView extends StatelessWidget {
  final bool isFiltering;

  const EmptyAlertsView({super.key, required this.isFiltering});

  @override
  Widget build(BuildContext context) {
    if (!isFiltering) {
      return const CustomEmptyState(
        icon: Icons.history,
        title: 'No SOS History',
        subtitle: 'When you trigger an SOS, it will be logged here.',
      );
    }

    return const CustomEmptyState(
      icon: Icons.event_busy,
      title: 'No Alerts in Range',
      subtitle: 'Try selecting a different date range.',
    );
  }
}
