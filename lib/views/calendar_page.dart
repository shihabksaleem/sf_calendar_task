import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sf;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/calendar_provider.dart';
import '../models/calendar_event.dart';
import 'widgets/calendar_data_source.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> with WidgetsBindingObserver {
  final sf.CalendarController _sfCalendarController = sf.CalendarController();
  DateTime? _lastVisibleMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().requestPermission();
      final now = DateTime.now();
      _lastVisibleMonth = DateTime(now.year, now.month);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sfCalendarController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final range = _sfCalendarController.displayDate ?? DateTime.now();
      _fetchEventsForDate(range);
    }
  }

  void _fetchEventsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    context.read<CalendarProvider>().loadEvents(start, end);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sfCalendarController.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _sfCalendarController.displayDate = picked;
        _sfCalendarController.selectedDate = picked;
      });
      _fetchEventsForDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<CalendarProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverFillRemaining(child: _buildMainContent(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final displayDate = _sfCalendarController.displayDate ?? DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(displayDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      floating: false,
      pinned: true,
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      title: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.05)
                : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthYear,
                style: GoogleFonts.outfit(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: isDark ? const Color(0xFFD3C7E6) : Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            final now = DateTime.now();
            setState(() {
              _sfCalendarController.displayDate = now;
              _sfCalendarController.selectedDate = now;
            });
            _fetchEventsForDate(now);
          },
          icon: Icon(Icons.today_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          label: Text(
            'Today',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _fetchEventsForDate(_sfCalendarController.displayDate ?? DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildMainContent(CalendarProvider provider) {
    switch (provider.status) {
      case CalendarStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case CalendarStatus.permissionDenied:
        return _buildPermissionDeniedState();
      case CalendarStatus.loaded:
        return _buildCalendarView(provider);
      case CalendarStatus.error:
        return _buildErrorState(provider.errorMessage ?? 'Unknown error');
      case CalendarStatus.initial:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCalendarView(CalendarProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 30, offset: const Offset(0, 15))],
        ),
        clipBehavior: Clip.antiAlias,
        child: sf.SfCalendar(
          view: sf.CalendarView.month,
          controller: _sfCalendarController,
          dataSource: CalendarEventDataSource(provider.events),
          headerHeight: 0,
          showNavigationArrow: false,
          cellBorderColor: Colors.transparent,
          monthViewSettings: sf.MonthViewSettings(
            appointmentDisplayMode: sf.MonthAppointmentDisplayMode.indicator,
            showAgenda: true,
            agendaViewHeight: 250,
            navigationDirection: sf.MonthNavigationDirection.horizontal,
            agendaItemHeight: 75,
            agendaStyle: sf.AgendaStyle(
              backgroundColor: Colors.transparent,
              dateTextStyle: GoogleFonts.outfit(fontSize: 12, color: onSurface.withValues(alpha: 0.5)),
              dayTextStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
            ),
            monthCellStyle: sf.MonthCellStyle(
              textStyle: GoogleFonts.outfit(fontSize: 14, color: onSurface),
              trailingDatesTextStyle: GoogleFonts.outfit(fontSize: 14, color: onSurface.withValues(alpha: 0.15)),
              leadingDatesTextStyle: GoogleFonts.outfit(fontSize: 14, color: onSurface.withValues(alpha: 0.15)),
            ),
          ),
          viewHeaderStyle: sf.ViewHeaderStyle(
            dayTextStyle: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: onSurface.withValues(alpha: 0.4),
            ),
          ),
          todayTextStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          onViewChanged: (details) {
            final visibleDate = details.visibleDates[details.visibleDates.length ~/ 2];
            final visibleMonth = DateTime(visibleDate.year, visibleDate.month);

            if (_lastVisibleMonth != visibleMonth) {
              _lastVisibleMonth = visibleMonth;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchEventsForDate(visibleMonth);
                if (mounted) setState(() {});
              });
            }
          },
          appointmentBuilder: (context, details) {
            final CalendarEvent event = details.appointments.first;
            return Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: event.color.withValues(alpha: isDark ? 0.2 : 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(color: event.color, borderRadius: BorderRadius.circular(2),),
                  ),
                  const SizedBox(width: 12),
                  Icon(event.icon, size: 20, color: isDark ? event.color : event.color.withValues(alpha: 0.8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${DateFormat('hh:mm a').format(event.startDate)} - ${DateFormat('hh:mm a').format(event.endDate)}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          todayHighlightColor: const Color(0xFFFED5CF),
          selectionDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.rectangle, // Switched to rectangular
            borderRadius: BorderRadius.circular(12), // Added rounded corners
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text('Access Required', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Please grant calendar access to view your events in this beautiful interface.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.read<CalendarProvider>().requestPermission(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Allow Access', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 100, color: Colors.redAccent.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text('Wait a minute...', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () => context.read<CalendarProvider>().requestPermission(),
            child: Text('Try Again', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
