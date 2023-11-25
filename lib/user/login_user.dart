// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/pages/homepage.dart';

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
        // final response = 
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // if (response.error != null) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(response.error!.message),
        //     ),
        //   );
        // } else {

        // * Successful login, navigate to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        // }
      } catch (error) {
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


// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:turf/pages/homepage.dart';

// class LoginUserPage extends StatefulWidget {
//   const LoginUserPage({Key? key}) : super(key: key);

//   @override
//   _LoginUserPageState createState() => _LoginUserPageState();
// }

// class _LoginUserPageState extends State<LoginUserPage> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   Future<void> _login() async {
//     final response = await Supabase.instance.client
//         .from('user')
//         .select()
//         .eq('email_id', _emailController.text)
//         .eq('user_password', _passwordController.text)
//         .execute();

//     if (response.data != null && (response.data as List).isNotEmpty) {
//       // Successful login, navigate to homepage
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//       );
//     } else {
//       // Invalid credentials
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid email or password'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

