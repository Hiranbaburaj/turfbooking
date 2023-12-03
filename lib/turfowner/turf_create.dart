import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MakeTurf extends StatefulWidget {
  final int ownerId;

  const MakeTurf({super.key, required this.ownerId});

  @override
  _MakeTurfState createState() => _MakeTurfState();
}

class _MakeTurfState extends State<MakeTurf> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _turfNameController = TextEditingController();
  final TextEditingController _turfLocationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _sportController = TextEditingController();
  String? _imageUrl; // * Variable to store the image URL
  int? _selectedCityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Turf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _turfNameController,
                decoration: const InputDecoration(labelText: 'Turf Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the turf name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _turfLocationController,
                maxLines: 3, // Increase the number of lines for the address
                decoration:
                    const InputDecoration(labelText: 'Turf Location (Address)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the turf location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _sportController,
                decoration: const InputDecoration(labelText: 'Sport'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sport';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              FutureBuilder(
                future: _getCityData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading city data');
                  } else {
                    final cityData = snapshot.data as List<dynamic>;
                    return DropdownButtonFormField<int>(
                      value: _selectedCityId,
                      items: cityData.map((city) {
                        return DropdownMenuItem<int>(
                          value: city['id'],
                          child: Text(city['city_name'].toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                        });
                      },
                      decoration:
                          const InputDecoration(labelText: 'Select City'),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    );
                  }
                },
              ),
              // * Button to upload image
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _uploadImage();
                },
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _createTurf();
                  }
                },
                child: const Text('Create Turf'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<dynamic>> _getCityData() async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('city').select('id, city_name').execute();
    return response.data as List<dynamic>;
  }

  Future<void> _uploadImage() async {
    final supabase = Supabase.instance.client;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // try {
      //   try {
      var timevar = DateTime.now().millisecondsSinceEpoch;
      String response = await supabase.storage.from('turfimages').upload(
            'public/turf_$timevar.jpg',
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // ignore: avoid_print
      print(response);
      // * Image upload successful, get the URL
      String imageUrl =
          supabase.storage.from('turfimages').getPublicUrl('public/turf_$timevar.jpg');
          // supabase.storage.from('turfimages').getPublicUrl(response);
      // ignore: avoid_print
      print(imageUrl);
      //*
      //*
      setState(() {
        _imageUrl = imageUrl;
      });
      // * Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully'),
        ),
      );
      //     } catch (error) {
      //       // * Image upload failed, show an error message
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(
      //           content: Text('Error uploading image'),
      //         ),
      //       );
      //     }
      //   } catch (error) {
      //     // ignore: avoid_print
      //     print('Error uploading image: $error');
      //   }
    }
  }

  Future<void> _createTurf() async {
    final supabase = Supabase.instance.client;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ownerName =
        prefs.getString('ownerFname') ?? ' ${prefs.getString('ownerLname')}';

    try {
      // ignore: unused_local_variable
      final response = await supabase.from('turf').upsert([
        {
          'turf_name': _turfNameController.text,
          'turf_location': _turfLocationController.text,
          'owner_name': ownerName,
          'turf_phone': _phoneNumberController.text,
          'sport': _sportController.text,
          'owner_id': widget.ownerId,
          'city_id': _selectedCityId,
          'image_url':
              _imageUrl, // * Update the image_url column with the uploaded image URL
        },
      ]);
      // Turf creation successful
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turf created successfully'),
        ),
      );
      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (error) {
      print('Error creating turf: $error ');
    }
  }
}
