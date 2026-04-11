import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';
import 'repositories/calendar_repository.dart';
import 'controllers/calendar_provider.dart';
import 'views/calendar_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final calendarRepository = CalendarRepository();

    return MultiProvider(
      providers: [
        Provider.value(value: calendarRepository),
        ChangeNotifierProvider(
          create: (context) => CalendarProvider(calendarRepository),
        ),
      ],
      child: MaterialApp(
        title: 'SF Calendar Task',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // Support system dark mode
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFED5CF),
            brightness: Brightness.light,
            surface: Colors.white,
          ),
          textTheme: GoogleFonts.outfitTextTheme(),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: GoogleFonts.outfit(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFED5CF),
            brightness: Brightness.dark,
            surface: const Color(0xFF101012),
            onSurface: Colors.white,
            primary: const Color(0xFFFED5CF),
          ),
          scaffoldBackgroundColor: const Color(0xFF101012),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: const Color(0xFF101012),
            titleTextStyle: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const CalendarPage(),
      ),
    );
  }
}
