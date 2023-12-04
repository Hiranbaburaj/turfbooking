import 'package:flutter/material.dart';
import 'package:turf/user/login_user1.dart';
import 'package:turf/user/signup_user.dart';
import 'package:turf/turfowner/login_owner.dart';
import 'package:turf/turfowner/signup_owner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turf Booking',
      theme: ThemeData.light(), // Light mode theme
      darkTheme: ThemeData.dark(), // Dark mode theme
      home: const HomePage(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to TurfBook',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Add space between the heading and buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginUserPage(),
                    ),
                  );
                },
                child: const Text(
                  'Login User',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10), // Add space between the buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserSignUp(),
                    ),
                  );
                },
                child: const Text(
                  'New User',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10), // Add space between the buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginOwnerPage(),
                    ),
                  );
                },
                child: const Text(
                  'Login Owner',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10), // Add space between the buttons
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerSignUp(),
                    ),
                  );
                },
                child: const Text(
                  'New Owner',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  