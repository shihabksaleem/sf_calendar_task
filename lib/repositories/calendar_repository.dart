import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/calendar_event.dart';

class CalendarRepository {
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  CalendarRepository({DeviceCalendarPlugin? deviceCalendarPlugin})
      : _deviceCalendarPlugin = deviceCalendarPlugin ?? DeviceCalendarPlugin();

  Future<bool> hasPermission() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    return permissionsGranted.isSuccess && permissionsGranted.data == true;
  }

  Future<bool> requestPermission() async {
    final permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
    return permissionsGranted.isSuccess && permissionsGranted.data == true;
  }

  Future<List<CalendarEvent>> getEvents(DateTime start, DateTime end) async {
    final List<CalendarEvent> allEvents = [];
    
    // 1. Get all calendars
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      return [];
    }

    // Convert DateTime to TZDateTime for device_calendar v4
    final tzStart = tz.TZDateTime.from(start, tz.local);
    final tzEnd = tz.TZDateTime.from(end, tz.local);

    // 2. Fetch events from each calendar
    for (final calendar in calendarsResult.data!) {
      if (calendar.id == null) continue;
      
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(startDate: tzStart, endDate: tzEnd),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        // Convert the int color to Color
        final Color calendarColor = calendar.color != null 
            ? Color(calendar.color!) 
            : Colors.blueAccent;

        allEvents.addAll(
          eventsResult.data!.map((event) => CalendarEvent.fromDeviceEvent(
            event, 
            calendarColor: calendarColor,
          )),
        );
      }
    }

    return allEvents;
  }
}
