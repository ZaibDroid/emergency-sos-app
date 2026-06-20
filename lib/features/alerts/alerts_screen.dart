import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alerts_provider.dart';
import 'widgets/alerts_filter_header.dart';
import 'widgets/empty_alerts_view.dart';
import 'widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AlertsProvider(),
      child: const _AlertsScreenView(),
    );
  }
}

class _AlertsScreenView extends StatelessWidget {
  const _AlertsScreenView();

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayedHistory = provider.filteredHistory;

        return Column(
          children: [
            // Filter Header
            const AlertsFilterHeader(),
            
            // List Body
            Expanded(
              child: provider.mySosHistory.isEmpty || displayedHistory.isEmpty
                ? EmptyAlertsView(
                    isFiltering: provider.mySosHistory.isNotEmpty && displayedHistory.isEmpty,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedHistory.length,
                    itemBuilder: (context, index) {
                      final alert = displayedHistory[index];
                      return AlertCard(alert: alert);
                    },
                  ),
            ),
          ],
        );
      },
    );
  }
}
