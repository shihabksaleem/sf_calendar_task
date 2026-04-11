import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/calendar_event.dart';

class CalendarEventDataSource extends CalendarDataSource {
  CalendarEventDataSource(List<CalendarEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getEventData(index).startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return _getEventData(index).endDate;
  }

  @override
  String getSubject(int index) {
    return _getEventData(index).title;
  }

  @override
  bool isAllDay(int index) {
    return _getEventData(index).isAllDay;
  }

  @override
  String? getNotes(int index) {
    return _getEventData(index).description;
  }

  @override
  Color getColor(int index) {
    return _getEventData(index).color;
  }

  CalendarEvent _getEventData(int index) {
    final dynamic appointment = appointments![index];
    late final CalendarEvent eventData;
    if (appointment is CalendarEvent) {
      eventData = appointment;
    }

    return eventData;
  }
}
