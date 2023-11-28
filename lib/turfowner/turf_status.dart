// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf/turfowner/slot_create.dart';
import 'package:turf/turfowner/turf_create.dart';

class TurfStatus extends StatefulWidget {
  final List<dynamic> owner;
  final List<dynamic> turfData;

  const TurfStatus({super.key, required this.owner, required this.turfData});

  @override
  State<TurfStatus> createState() => _TurfStatusState();
}

class _TurfStatusState extends State<TurfStatus> {
  String eMail = '';
  int ownerId = 0; // Add this line

  @override
  void initState() {
    super.initState();
    getOwnerInfo();
    getmailofOwner();
  }

  Future<void> getOwnerInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ownerId = prefs.getInt('ownerId') ?? 0; // Set a default value if not found
    setState(() {});
  }

  Future getmailofOwner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    eMail = prefs.getString('email').toString();
    setState(() {});
  }

  Future<void> _logout() async {
    // * Clear SharedPreferences entry
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('ownerId');
    // * Navigate to the home page
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turf Status'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // * Display owner details
            const Text(
              'Owner Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
                'Welcome ${widget.owner[0]['f_name']} ${widget.owner[0]['l_name']} $eMail'),
            // Text('Last Name: ${widget.owner[0]['l_name']}'),
            const SizedBox(height: 20),

            // * Display turf details
            const Text(
              'Turf Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (final turf in widget.turfData)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Turf Name: ${turf['turf_name']}'),
                  Text('Turf Location: ${turf['turf_location']}'),
                  const SizedBox(height: 10),

                  // Display slot details
                  const Text(
                    'Slot Details:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                    future: _getSlots(turf['id'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error loading slot details');
                      } else {
                        final slots = snapshot.data as List<dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final slot in slots)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Starting Time: ${slot['startingtime']}'),
                                  Text('Ending Time: ${slot['endingtime']}'),
                                  Text(
                                      'Booking Status: ${slot['status'] ? 'Booked' : 'Available'}'),
                                  const SizedBox(height: 10),
                                ],
                              ),
                          ],
                        );
                      }
                    },
                  ),

                  // Display booked tickets
                  const Text(
                    'Booked Tickets:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                    future: _getBookedTickets(turf['id'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error loading booked tickets');
                      } else {
                        final bookedTickets = snapshot.data as List<dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final ticket in bookedTickets)
                              FutureBuilder(
                                future: _getUserDetails(
                                    ticket['user_id'].toString()),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (userSnapshot.hasError) {
                                    return const Text(
                                        'Error loading user details');
                                  } else {
                                    final user = userSnapshot.data
                                        as Map<String, dynamic>;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'User Name: ${user['fname']} ${user['lname']}'),
                                        Text('User Email: ${user['email']}'),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  }
                                },
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            // Button to navigate to the SlotMake page
            ElevatedButton(
              onPressed: () {
                // ignore: avoid_print
                print(ownerId);        
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SlotMake(
                      ownerId: ownerId, // Pass ownerId to SlotMake
                      turfData: widget.turfData,
                    ),
                  ),
                );
              },
              child: const Text('Create Slot'),
            ),
            ElevatedButton(
              onPressed: () {
                // ignore: avoid_print
                print(ownerId);
                // if (widget.turfData[0]['turf_name'] != null) {
                //   // ignore: avoid_print
                //   print(widget.turfData[0]['turf_name']);
                // }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeTurf(
                      ownerId: ownerId, // Pass ownerId to SlotMake
                    ),
                  ),
                );
              },
              child: const Text('Create new Turf'),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to get slots for a turf
Future<List<dynamic>> _getSlots(String turfId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('slot').select().eq('turf_id', turfId).execute();
  return response.data as List<dynamic>;
}

// Function to get booked tickets for a turf
Future<List<dynamic>> _getBookedTickets(String turfId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('booking').select().eq('turf_id', turfId).execute();
  return response.data as List<dynamic>;
}

// Function to get user details for a booked ticket
Future<Map<String, dynamic>> _getUserDetails(String userId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('user').select().eq('id', userId).execute();
  return response.data[0] as Map<String, dynamic>;
}
