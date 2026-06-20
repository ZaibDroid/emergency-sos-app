import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class AlertsProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<Map<String, dynamic>> _mySosHistory = [];
  bool _isLoading = true;
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> get mySosHistory => _mySosHistory;
  bool get isLoading => _isLoading;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  AlertsProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _isLoading = true;
    notifyListeners();

    _mySosHistory = await _storageService.getSosHistory();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAlert(String timestamp) async {
    _mySosHistory.removeWhere((alert) => alert['timestamp'] == timestamp);
    notifyListeners();
    await _storageService.deleteSosEvent(timestamp);
  }

  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  void clearDates() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> get filteredHistory {
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
}
