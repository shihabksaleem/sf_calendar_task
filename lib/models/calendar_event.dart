import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isAllDay;
  final Color color;
  final IconData icon;

  // Custom Pastel Palette
  static const Color pastelBlue = Color(0xFFBEDAE3);
  static const Color pastelGreen = Color(0xFFC4E9DA);
  static const Color pastelPink = Color(0xFFFED5CF);
  static const Color pastelOrange = Color(0xFFF1B598);
  static const Color pastelPurple = Color(0xFFD3C7E6);

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.isAllDay = false,
    this.color = pastelBlue,
    required this.icon,
  });

  factory CalendarEvent.fromDeviceEvent(Event event, {Color? calendarColor}) {
    final start = event.start;
    final end = event.end;
    final title = event.title ?? 'No Title';
    final description = event.description ?? '';
    
    final inferredData = _inferVisuals(title, description);

    return CalendarEvent(
      id: event.eventId ?? '',
      title: title,
      description: description,
      startDate: start != null 
          ? DateTime.fromMillisecondsSinceEpoch(start.millisecondsSinceEpoch) 
          : DateTime.now(),
      endDate: end != null 
          ? DateTime.fromMillisecondsSinceEpoch(end.millisecondsSinceEpoch) 
          : DateTime.now().add(const Duration(hours: 1)),
      isAllDay: event.allDay ?? false,
      color: inferredData.color,
      icon: inferredData.icon,
    );
  }

  static ({IconData icon, Color color}) _inferVisuals(String title, String description) {
    final text = '$title $description'.toLowerCase();
    
    if (text.contains('meeting') || text.contains('sync') || text.contains('call')) {
      return (icon: Icons.groups_rounded, color: pastelBlue);
    } else if (text.contains('birthday') || text.contains('party') || text.contains('cake') || text.contains('celebration')) {
      return (icon: Icons.cake_rounded, color: pastelPink);
    } else if (text.contains('flight') || text.contains('travel') || text.contains('trip') || text.contains('vacation')) {
      return (icon: Icons.flight_takeoff_rounded, color: pastelPurple);
    } else if (text.contains('gym') || text.contains('workout') || text.contains('run') || text.contains('training') || text.contains('fitness')) {
      return (icon: Icons.fitness_center_rounded, color: pastelGreen);
    } else if (text.contains('doctor') || text.contains('hospital') || text.contains('appointment') || text.contains('dentist') || text.contains('health')) {
      return (icon: Icons.medical_services_rounded, color: pastelGreen);
    } else if (text.contains('lunch') || text.contains('dinner') || text.contains('food') || text.contains('restaurant')) {
      return (icon: Icons.restaurant_rounded, color: pastelOrange);
    } else if (text.contains('shopping') || text.contains('buy') || text.contains('store')) {
      return (icon: Icons.shopping_bag_rounded, color: pastelOrange);
    } else if (text.contains('deadline') || text.contains('due') || text.contains('submit') || text.contains('task')) {
      return (icon: Icons.notification_important_rounded, color: pastelPurple);
    }
    
    // Default fallback cycling colors or random
    return (icon: Icons.event_note_rounded, color: pastelBlue);
  }
}
