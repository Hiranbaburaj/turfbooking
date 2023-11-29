import 'package:flutter/material.dart';
import 'package:turf/turfowner/signup_owner.dart';
import 'package:turf/user/login_user1.dart';
import 'package:turf/turfowner/login_owner.dart';
import 'package:turf/user/signup_user.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homepage',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Welcome to Turf booking',
            style: TextStyle(
              color: Colors.white, // Set text color to white
              fontSize: 24.0, // Set font size to 24.0
            ),
          ),// Use the specified color
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
                        builder: (context) => const LoginUserPage()),
                  );
                },
                child: const Text('Login User'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserSignUp()),
                  );
                },
                child: const Text('New User'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginOwnerPage()),
                  );
                },
                child: const Text('Login Owner'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OwnerSignUp()),
                  );
                },
                child: const Text('New Owner'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
