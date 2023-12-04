import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turf/turfowner/slot_create.dart';
import 'package:turf/turfowner/turf_create.dart';
import 'package:turf/turfowner/turf_update.dart';

class TurfStatus extends StatefulWidget {
  final List<dynamic> owner;
  final List<dynamic> turfData;

  const TurfStatus({super.key, required this.owner, required this.turfData});

  @override
  State<TurfStatus> createState() => _TurfStatusState();
}

class _TurfStatusState extends State<TurfStatus> {
  String eMail = '';
  int ownerId = 0;

  @override
  void initState() {
    super.initState();
    getOwnerInfo();
    getmailofOwner();
  }

  Future<void> getOwnerInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ownerId = prefs.getInt('ownerId') ?? 0;
    setState(() {});
  }

  Future getmailofOwner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    eMail = prefs.getString('email').toString();
    setState(() {});
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email');
    prefs.remove('password');
    prefs.remove('ownerId');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // * Drawer Button Color
        title: const Text(
          'Turf Status',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 20.0, // Set font size to 24.0
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome ${widget.owner[0]['f_name']} ${widget.owner[0]['l_name']}!',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    eMail,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Create Slot'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SlotMake(
                      ownerId: ownerId,
                      turfData: widget.turfData,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Create new Turf'),
              onTap: () {
                print(ownerId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeTurf(
                      ownerId: ownerId,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Update Turf Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TurfUpdate(
                      ownerId: ownerId,
                      turfData: widget.turfData,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: Text(
                'Logout',
                style: GoogleFonts.raleway(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              leading: const Icon(
                CupertinoIcons.arrow_left_to_line_alt,
                size: 27,
                semanticLabel: 'Logout',
                color: Colors.red,
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final turf in widget.turfData)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // * Display turf details
                    const Text(
                      'Turf Details:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Turf Name: ${turf['turf_name']}'),
                    Text('Turf Location: ${turf['turf_location']}'),
                    const SizedBox(height: 20),
                    // * Display Booking details
                    const Text(
                      'Booking Details:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    FutureBuilder(
                      future: _getSlots(turf['id'].toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                    Text('Date: ${slot['date']}'),
                                    Text(
                                        'Starting Time: ${slot['startingtime']}'),
                                    Text('Ending Time: ${slot['endingtime']}'),
                                    Text(
                                        'Booking Status: ${slot['status'] ? 'Booked' : 'Available'}'),
                                    if (slot['status'])
                                      FutureBuilder(
                                        future: _getBookingDetails(
                                            slot['id'].toString()),
                                        builder: (context, bookingSnapshot) {
                                          if (bookingSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (bookingSnapshot.hasError) {
                                            return const Text(
                                                'Error loading booking details');
                                          } else {
                                            final bookingDetails =
                                                bookingSnapshot.data
                                                    as Map<String, dynamic>;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Slot ID: ${slot['id']}'),
                                                // Text('Booking Date: ${bookingDetails['date']}'),
                                                // Text(
                                                //     'Booking Starting Time: ${bookingDetails['startingtime']}'),
                                                // Text(
                                                //     'Booking Ending Time: ${bookingDetails['endingtime']}'),
                                                FutureBuilder(
                                                  future: _getUserDetails(
                                                      bookingDetails['user_id']
                                                          .toString()),
                                                  builder:
                                                      (context, userSnapshot) {
                                                    if (userSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const CircularProgressIndicator();
                                                    } else if (userSnapshot
                                                        .hasError) {
                                                      return const Text(
                                                          'Error loading user details');
                                                    } else {
                                                      final user =
                                                          userSnapshot.data
                                                              as Map<String,
                                                                  dynamic>;
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'User Name: ${user['fname']} ${user['lname']}'),
                                                          Text(
                                                              'User Email: ${user['email']}'),
                                                          Text(
                                                              'User Phone: ${user['phone']}'),
                                                          const SizedBox(
                                                              height: 10),
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
                                    const SizedBox(height: 10),
                                  ],
                                ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// * Function to get slots for a turf
Future<List<dynamic>> _getSlots(String turfId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('slot').select().eq('turf_id', turfId).execute();
  return response.data as List<dynamic>;
}

// * Function to get user details for a booked ticket
Future<Map<String, dynamic>> _getUserDetails(String userId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('user').select().eq('id', userId).execute();
  return response.data[0] as Map<String, dynamic>;
}

// * Function to get Booking Details
Future<Map<String, dynamic>> _getBookingDetails(String slotId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('booking')
      .select()
      .eq('slot_id', slotId)
      .limit(1)
      .execute();
  return response.data[0] as Map<String, dynamic>;
}
