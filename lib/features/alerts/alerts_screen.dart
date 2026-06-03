import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> _mySosHistory = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _clearDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyStrings = prefs.getStringList('sos_history');
    
    if (historyStrings != null) {
      setState(() {
        _mySosHistory = historyStrings.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
        // Reverse so newest is at the top
        _mySosHistory = _mySosHistory.reversed.toList();
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteAlert(Map<String, dynamic> alertToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mySosHistory.removeWhere((alert) => alert['timestamp'] == alertToDelete['timestamp']);
    });
    // Save back to prefs (reverse it back to chronological order)
    final listToSave = _mySosHistory.reversed.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('sos_history', listToSave);
  }

  Future<void> _showContactsDialog(Map<String, dynamic> alert) async {
    List<dynamic>? contacts = alert['contacts'];
    
    // Fallback for older alerts that didn't save the contact list internally
    if (contacts == null || contacts.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final String? contactsJson = prefs.getString('trusted_contacts');
      if (contactsJson != null) {
        contacts = jsonDecode(contactsJson) as List<dynamic>;
      }
    }

    if (contacts == null || contacts.isEmpty) {
      Fluttertoast.showToast(msg: 'No contact details found.', gravity: ToastGravity.BOTTOM);
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sent to Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: contacts!.map((c) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    c['name'] != null && c['name'].toString().isNotEmpty ? c['name'][0].toUpperCase() : '?',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
                title: Text(c['name'] ?? 'Unknown'),
                subtitle: Text(c['phoneNumber'] ?? ''),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> get _filteredHistory {
    if (_startDate == null && _endDate == null) return _mySosHistory;

    return _mySosHistory.where((alert) {
      final timestampStr = alert['timestamp'] as String?;
      if (timestampStr == null) return false;
      try {
        final date = DateTime.parse(timestampStr).toLocal();
        bool isAfterStart = true;
        bool isBeforeEnd = true;

        if (_startDate != null) {
          final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          isAfterStart = date.isAfter(start.subtract(const Duration(seconds: 1)));
        }

        if (_endDate != null) {
          final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          isBeforeEnd = date.isBefore(end);
        }

        return isAfterStart && isBeforeEnd;
      } catch (e) {
        return false;
      }
    }).toList();
  }

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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayedHistory = _filteredHistory;

    return Column(
      children: [
        // Filter Header
        Container(
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
                  if (_startDate != null || _endDate != null)
                    TextButton.icon(
                      onPressed: _clearDates,
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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickStartDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_startDate == null ? 'Start Date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickEndDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_endDate == null ? 'End Date' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${displayedHistory.length} Alerts Found',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        
        // List Body
        Expanded(
          child: _mySosHistory.isEmpty
            ? Center(
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
              )
            : displayedHistory.isEmpty
              ? Center(
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
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayedHistory.length,
                  itemBuilder: (context, index) {
                    final alert = displayedHistory[index];
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
                        _deleteAlert(alert);
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
                                onTap: () => _showContactsDialog(alert),
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
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: mapsLink.isNotEmpty ? () => _openMap(mapsLink) : null,
                                  icon: const Icon(Icons.map),
                                  label: const Text('View Location Sent'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
