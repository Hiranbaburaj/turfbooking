// ignore_for_file: deprecated_member_use, unnecessary_cast, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf/turfowner/turf_status.dart';

class LoginOwnerPage extends StatefulWidget {
  const LoginOwnerPage({super.key});
  
  @override
  _LoginOwnerPageState createState() => _LoginOwnerPageState();
}

class _LoginOwnerPageState extends State<LoginOwnerPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  //* Save login information
  // * Make sure to call this function when you want to save the login information, such as after a successful login.
  Future<void> saveLoginInfo(String email, String password, int ownerId, String ownerFname, String ownerLname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);
    prefs.setInt('ownerId', ownerId);
    prefs.setString('ownerFname', ownerFname);
    prefs.setString('ownerLname', ownerLname);
  }

  Future<void> _login() async {
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final response = await supabase
        .from('turf_owner')
        .select()
        .eq('mail', email)
        .eq('owner_password', password)
        .execute();

    if (response.data != null && (response.data as List).isNotEmpty) {
      // * Fetch owner information from the 'turf_owner' table
      final ownerResponse = await supabase
          .from('turf_owner')
          .select()
          .eq('mail', email)
          .execute();

      // * Check if owner information is available
      if (ownerResponse.data != null && ownerResponse.data.isNotEmpty) {

        // * Extract owner ID from the response
        final ownerId = ownerResponse.data[0]['id'];

        // * Extract owner FirstName from the response
        final ownerFname = ownerResponse.data[0]['f_name'];

        // * Extract owner FirstName from the response
        final ownerLname = ownerResponse.data[0]['l_name'];

        // * Fetch turf information from the 'turf' table where 'owner_id' matches 'id' in 'turf_owner' table
        final turfResponse = await supabase
            .from('turf')
            .select()
            .eq('owner_id', ownerId)
            .execute();

        // * Extract data
        final owner = ownerResponse.data as List<dynamic>;
        final turfData = turfResponse.data as List<dynamic>;

        // * Save login information using shared_preferences
        await saveLoginInfo(email, password, ownerId, ownerFname, ownerLname);

        //* Successful login, navigate to homepage

        Navigator.pushReplacement(
          context as BuildContext,
          MaterialPageRoute(
            builder: (context) => WillPopScope(
              onWillPop: () async => false, // * Disable back button
              child: TurfStatus(owner: owner, turfData: turfData),
            ),
          ),
        );
      } else {
        // Invalid credentials

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text('Invalid email or password'),
          ),
        );
      }
    }
  }
}
