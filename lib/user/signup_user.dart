// ignore_for_file: use_super_parameters, use_build_context_synchronously, library_private_types_in_public_api, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/user/login_user1.dart';

class UserSignUp extends StatefulWidget {
  const UserSignUp({Key? key}) : super(key: key);

  @override
  _UserSignUpState createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser(BuildContext context) async {
    final supabase = Supabase.instance.client;

    // Register the user with email and password
    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    print(response);

    // if (response.error == null) {
    // If registration is successful, add user details to the 'user' table
    final userResponse = await supabase.from('user').upsert([
      {
        'id': response.user!.id,
        'fname': _firstNameController.text.trim(),
        'lname': _lastNameController.text.trim(),
        'age': _ageController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      },
    ]).execute();

    // if (userResponse.error == null) {
    // After successful registration, navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginUserPage(),
      ),
    );
    // } else {
    //   // Handle error while adding user details to the 'user' table
    //   // You may want to display an error message or take appropriate action
    //   print('Error adding user details to the database: ${userResponse.error}');
    // }
    // } else {
    //   // Handle registration error
    //   // You may want to display an error message or take appropriate action
    //   print('Error registering user: ${response.error}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _registerUser(context),
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
