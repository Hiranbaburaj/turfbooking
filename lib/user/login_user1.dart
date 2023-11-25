import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/pages/turf_select.dart';

class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginUserPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final supabase = Supabase.instance.client;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
        ),
      );
    } else {
      try {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // if (response.error != null) {
        //   throw response.error!;
        // }

        // * Fetch user information from the 'user' table
        final userResponse = await supabase.from('user').select().eq('id', response.user!.id).execute();
        // * Fetch turf information from the 'turf' table
        final turfResponse = await supabase.from('turf').select().execute();

        // if (userResponse.error != null) {
        //   throw userResponse.error!;
        // }

        final user = userResponse.data as List<dynamic>;
        final turfData = turfResponse.data as List<dynamic>;
        
        // * Navigate to TurfSelect with user information
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // ignore: deprecated_member_use
            builder: (context) => WillPopScope(
              onWillPop: () async => false, // Disable back button
              child: TurfSelect(user: user, turfData: turfData),
            ),
          ),
        );
      } catch (error) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
          ),
        );
      }
    }
  }

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
}
