import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../repositories/calendar_repository.dart';

enum CalendarStatus { initial, loading, loaded, error, permissionDenied }

class CalendarProvider extends ChangeNotifier {
  final CalendarRepository _repository;

  CalendarProvider(this._repository);

  CalendarStatus _status = CalendarStatus.initial;
  CalendarStatus get status => _status;

  List<CalendarEvent> _events = [];
  List<CalendarEvent> get events => _events;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> requestPermission() async {
    _status = CalendarStatus.loading;
    notifyListeners();

    try {
      final granted = await _repository.requestPermission();
      if (granted) {
        // Automatically load events for the current month if permission granted
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        await loadEvents(start, end);
      } else {
        _status = CalendarStatus.permissionDenied;
        notifyListeners();
      }
    } catch (e) {
      _status = CalendarStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadEvents(DateTime start, DateTime end) async {
    _status = CalendarStatus.loading;
    notifyListeners();

    try {
      final hasPermission = await _repository.hasPermission();
      if (!hasPermission) {
        _status = CalendarStatus.permissionDenied;
        notifyListeners();
        return;
      }

      _events = await _repository.getEvents(start, end);
      _status = CalendarStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = CalendarStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
