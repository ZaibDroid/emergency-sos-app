import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/alerts_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'alert_contacts_dialog.dart';

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertCard({super.key, required this.alert});

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      
      final today = DateTime(now.year, now.month, now.day);
      final aDate = DateTime(date.year, date.month, date.day);
      final difference = today.difference(aDate).inDays;

      String timeStr = '${date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
      
      if (difference == 0) {
        return 'Today at $timeStr';
      } else if (difference == 1) {
        return 'Yesterday at $timeStr';
      }
      
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year} at $timeStr';
    } catch (e) {
      return 'Unknown date';
    }
  }

  Future<void> _openMap(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = alert['timestamp'] ?? '';
    final mapsLink = alert['mapsLink'] ?? '';
    final status = alert['status'] ?? 'Sent';

    return Dismissible(
      key: Key(timestamp),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      onDismissed: (direction) {
        context.read<AlertsProvider>().deleteAlert(timestamp);
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.outbound, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SOS Triggered', style: theme.textTheme.titleMedium),
                        Text(_formatDate(timestamp), style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sent',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  AlertContactsDialog.show(context, alert);
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(status, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
                      const SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                onPressed: mapsLink.isNotEmpty ? () => _openMap(mapsLink) : () {},
                icon: Icons.map,
                label: 'View Location Sent',
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
