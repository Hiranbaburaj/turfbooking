import 'package:flutter/material.dart';
import 'package:turf/user/login_user1.dart';
import 'package:turf/user/signup_user.dart';
import 'package:turf/turfowner/login_owner.dart';
import 'package:turf/turfowner/signup_owner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turf Booking',
      theme: ThemeData.light(), // Light mode theme
      darkTheme: ThemeData.dark(), // Dark mode theme
      home: HomePage(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Turf Booking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginUserPage(),
                  ),
                );
              },
              child: const Text('Login User'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserSignUp(),
                  ),
                );
              },
              child: const Text('New User'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginOwnerPage(),
                  ),
                );
              },
              child: const Text('Login Owner'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerSignUp(),
                  ),
                );
              },
              child: const Text('New Owner'),
            ),
          ],
        ),
      ),
    );
  }
}
