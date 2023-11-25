import 'package:flutter/material.dart';
import 'package:turf/pages/homepage.dart';
import 'package:turf/pages/turf_select.dart';
import 'package:turf/user/login_user1.dart';
import 'package:turf/user/signup_user.dart';
import 'package:turf/booking/slot_select.dart';
import 'package:turf/booking/slot_empty.dart';
import 'package:turf/turfowner/login_owner.dart';
import 'package:turf/turfowner/turf_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //* JOpYt3O99TQ6ZzyT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lxcpligadiiloqwchlya.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx4Y3BsaWdhZGlpbG9xd2NobHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAyNDgyMjksImV4cCI6MjAxNTgyNDIyOX0.oAgW6n84mP5zob01jHJfXmOPnd6W5QMfd31Z7wCJVsg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  get user => null;
  get turfData => null;
  get selectedSlot => null;
  get owner => null;
  
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Turf",
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login_user1' :(context) => const LoginUserPage(),
        '/signup_user' :(context) => const UserSignUp(),
        '/turf_select' :(context) => TurfSelect(user: user, turfData: turfData),
        '/slot_select' :(context) => SlotSelection(user: user, turfData: turfData, selectedSlot: selectedSlot),
        '/slot_empty'  :(context) => SlotIsEmpty(user: user, turfData: turfData, selectedSlot: selectedSlot),
        '/login_owner' :(context) => const LoginOwnerPage(),
        '/turf_status' :(context) => TurfStatus(owner: owner, turfData: turfData),
      },
    );
  }
}

