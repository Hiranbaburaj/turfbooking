import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserUpdateDetails extends StatefulWidget {
  final List<dynamic> user;

  const UserUpdateDetails({Key? key, required this.user}) : super(key: key);

  @override
  _UserUpdateDetailsState createState() => _UserUpdateDetailsState();
}

class _UserUpdateDetailsState extends State<UserUpdateDetails> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user data
    _firstNameController.text = widget.user[0]['fname'];
    _lastNameController.text = widget.user[0]['lname'];
    _ageController.text = widget.user[0]['age'].toString();
    _phoneController.text = widget.user[0]['phone'].toString();
    _emailController.text = widget.user[0]['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _updateUserDetails();
                    }
                  },
                  child: const Text('Update Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateUserDetails() async {
    final supabase = Supabase.instance.client;

    try {
      // ignore: unused_local_variable
      final userResponse = await supabase.auth.updateUser(
        UserAttributes(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      // * Update user details in 'user' table
      final userId = widget.user[0]['id'].toString();
      await supabase
          .from('user')
          .update({
            'fname': _firstNameController.text,
            'lname': _lastNameController.text,
            'age': int.parse(_ageController.text),
            'phone': int.parse(_phoneController.text),
            'email': _emailController.text,
          })
          .eq('id', userId)
          .execute();
    } catch (error) {
      // * Handle error updating user details
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user details: $error'),
        ),
      );
      return;
    }

    // * Show success message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User details updated successfully')),
    );

    // * Navigate back to the previous page
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
