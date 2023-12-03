import 'package:flutter/material.dart';
import 'package:turf/pages/homepage.dart';
import 'package:turf/pages/turf_select.dart';
import 'package:turf/turfowner/turf_create.dart';
import 'package:turf/user/login_user1.dart';
import 'package:turf/user/signup_user.dart';
import 'package:turf/booking/slot_select.dart';
import 'package:turf/booking/slot_empty.dart';
import 'package:turf/turfowner/login_owner.dart';
import 'package:turf/turfowner/signup_owner.dart';
import 'package:turf/turfowner/turf_status.dart';
import 'package:turf/turfowner/slot_create.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //* JOpYt3O99TQ6ZzyT
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lxcpligadiiloqwchlya.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4Y3BsaWdhZGlpbG9xd2NobHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAyNDgyMjksImV4cCI6MjAxNTgyNDIyOX0.oAgW6n84mP5zob01jHJfXmOPnd6W5QMfd31Z7wCJVsg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get user => null;
  get turfData => null;
  get selectedSlot => null;
  get owner => null;
  get ownerId => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Turf",

      theme: ThemeData(
        primarySwatch: Colors.green,
        appBarTheme: AppBarTheme(
          color: Colors.green,
          titleTextStyle: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.raleway(fontSize: 16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.amberAccent,
          unselectedItemColor: Colors.white,
        ),
        scaffoldBackgroundColor:
            Colors.grey.shade200, // Light grey background color
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        appBarTheme: AppBarTheme(
          color: Colors.green,
          titleTextStyle: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.raleway(fontSize: 16),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade400,
        ),
        scaffoldBackgroundColor:
            Colors.grey[900], // Dark grey background color
      ),

      // You can enable or disable dark mode based on user preference
      themeMode: ThemeMode.system,

      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login_user1': (context) => const LoginUserPage(),
        '/signup_user': (context) => const UserSignUp(),
        '/turf_select': (context) => TurfSelect(user: user, turfData: turfData),
        '/slot_select': (context) => SlotSelection(
            user: user, turfData: turfData, selectedSlot: selectedSlot),
        '/slot_empty': (context) => SlotIsEmpty(
            user: user, turfData: turfData, selectedSlot: selectedSlot),
        '/login_owner': (context) => const LoginOwnerPage(),
        '/signup_owner': (context) => const OwnerSignUp(),
        '/turf_status': (context) =>
            TurfStatus(owner: owner, turfData: turfData),
        '/slot_create': (context) =>
            SlotMake(ownerId: ownerId, turfData: turfData),
        '/turf_create': (context) => MakeTurf(ownerId: ownerId),
      },
    );
  }
}
