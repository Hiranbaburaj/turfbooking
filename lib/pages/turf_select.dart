// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/booking/slot_select.dart';
import 'package:turf/booking/slot_empty.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

class TurfSelect extends StatefulWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;
  const TurfSelect({super.key, required this.user, required this.turfData});

  @override
  // ignore: library_private_types_in_public_api
  _TurfSelectState createState() => _TurfSelectState();
}

class _TurfSelectState extends State<TurfSelect> {
  int _selectedIndex = 0; // * Index for the selected bottom navigation bar item
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  // Function to handle bottom navigation bar item selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // * Function to log out and navigate to the home page
  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Colors.white), // * Drawer Button Color
        title: const Text(
          'Turf Select',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 20.0, // Set font size to 24.0
          ),
        ),
      ),
      body: _selectedIndex ==
              0 // * Display available slots or booked slots based on the selected tab
          ? _buildAvailableSlots() // * Function to build the available slots view
          : _buildBookedSlots(), // * Function to build the booked slots view
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: Colors.white)),
        child: CurvedNavigationBar(
          animationCurve: Curves.decelerate,
          animationDuration: const Duration(milliseconds: 500),
          color: Colors.green,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.red[300],
          index: _selectedIndex,
          height: 60.0,
          items: [
            CurvedNavigationBarItem(
              child: const Icon(Icons.event_available, size: 30),
              label: 'Available Turfs',
              labelStyle:
                  GoogleFonts.instrumentSans(color: Colors.white, fontSize: 13),
            ),
            CurvedNavigationBarItem(
              child: const Icon(Icons.event_busy, size: 30),
              label: 'Your Bookings',
              labelStyle:
                  GoogleFonts.instrumentSans(color: Colors.white, fontSize: 13),
            ),
          ],
          iconPadding: 11,
          onTap: _onItemTapped,
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
                    'Welcome, ${widget.user[0]['fname']} ${widget.user[0]['lname']}!',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // ... Add any other user information you want to display in the drawer header
                ],
              ),
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
                color: Colors.red, // Set the icon color to red
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  String? _selectedCityId;
  // * Function to build the view for available slots
  Widget _buildAvailableSlots() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // * SizedBox

          // * DropdownButton for selecting cities
          FutureBuilder(
            future:
                _getCityData(), // Fetch available cities from the 'city' table
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading cities');
              } else {
                final cityData = snapshot.data as List<dynamic>;

                return DropdownButton<String>(
                  value: _selectedCityId,
                  items: cityData.map((city) {
                    final cityName = city['city_name'].toString();
                    final cityId = city['id'].toString();
                    return DropdownMenuItem<String>(
                      value: cityId,
                      child: Text(
                        cityName,
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ), // * Apply Barlow Condensed font
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                    });
                  },
                  hint: Text(
                    'Select City',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 20,
                    ), // * Apply Barlow Condensed font
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 30), // * SizedBox
          Expanded(
            child: FutureBuilder(
              future: _getTurfsByCity(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading turfs'));
                } else {
                  final filteredTurfData = snapshot.data as List<dynamic>;

                  return SingleChildScrollView(
                    child: CarouselSlider.builder(
                      itemCount: filteredTurfData.length,
                      itemBuilder: (context, index, realIndex) {
                        final turf = filteredTurfData[index];
                        final imageUrl = turf['image_url'];

                        return InkWell(
                          onTap: () {
                            _slotselect(context, turf['id']);
                          },
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                width: 2,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : const Color.fromARGB(255, 231, 231, 231),
                              ),
                            ),
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${turf['turf_name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Owner: ${turf['owner_name']}',
                                  ),
                                  Text(
                                    'Phone: ${turf['turf_phone']}',
                                  ),
                                  Text(
                                    'Location: ${turf['turf_location']}',
                                  ),
                                  const SizedBox(height: 20.0),
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.height *
                            0.38, // * Adjust the height as needed
                        aspectRatio: 2.0,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        viewportFraction: 0.75, // * Size of carousel
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // * Function to build the view for booked slots
  Widget _buildBookedSlots() {
    return FutureBuilder(
      future: _getBookedSlots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading booked slots'));
        } else {
          final bookedSlots = snapshot.data as List<dynamic>;

          return bookedSlots.isEmpty
              ? const Center(child: Text('No booked slots available'))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: bookedSlots.length,
                  itemBuilder: (context, index) {
                    final bookedSlot = bookedSlots[index];
                    return Column(
                      children: [
                        ListTile(
                          title: FutureBuilder(
                            future:
                                _getTurfName(bookedSlot['turf_id'].toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text('Error loading turf name');
                              } else {
                                final turfName = snapshot.data as String;
                                return Text('Turf: $turfName');
                              }
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: _getSlotTiming(
                                    bookedSlot['slot_id'].toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text(
                                        'Error loading slot timing');
                                  } else {
                                    final timing = snapshot.data as String;
                                    return Text('Timing: $timing');
                                  }
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Add logic to cancel booking
                                  _cancelBooking(
                                      bookedSlot['slot_id'].toString(),
                                      bookedSlot['id'].toString());
                                },
                                child: const Text('Cancel Booking'),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                );
        }
      },
    );
  }

  // * Function to cancel booking
  Future<void> _cancelBooking(String slotId, String userID) async {
    dynamic slotResponse;
    final supabase = Supabase.instance.client;
    // * Get the slot information
    try {
      slotResponse =
          await supabase.from('slot').select().eq('id', slotId).execute();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching slot information'),
        ),
      );
      return;
    }

    final slot = slotResponse.data![0];

    // * Get the current time
    final currentTime = DateTime.now();
    // * Parse starting time from the slot information
    final startingTime =
        DateFormat('HH:mm').parse(slot['startingtime'].toString());

    // * Check if the current time is less than 3 hours before starting time or event date is before the current date
    if (DateTime.parse(slot['date'].toString()).isAfter(currentTime) ||
        (DateTime.parse(slot['date'].toString())
                .isAtSameMomentAs(currentTime) &&
            currentTime
                .isAfter(startingTime.subtract(const Duration(hours: 3))))) {
      // * Set the status to false in the 'slot' table
      try {
        // * Delete the row in the 'booking' table
        try {
          // * Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking successfully canceled'),
            ),
          );
        } catch (error) {
          // Handle error while deleting booking record
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error deleting booking record'),
            ),
          );
        }
      } catch (error) {
        // Handle error while updating slot status
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating slot status'),
          ),
        );
      }
    } else {
      // Unable to cancel booking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to cancel booking'),
        ),
      );
    }

    // *Refresh the UI or update the booked slots list
    setState(() {
      // Call the function that fetches booked slots again
      _getBookedSlots();
    });
  }

  // * Function to format the date in "dd-mm-yyyy" format
  String convertDateFormat(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year.toString()}";
    return formattedDate;
  }

  Future<List<dynamic>> _getCityData() async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('city').select('id, city_name').execute();
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> _getTurfsByCity() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('turf')
        .select()
        .eq('city_id', _selectedCityId)
        .execute();
    return response.data as List<dynamic>;
  }

  //* Function to get the list of booked slots from the 'booking' table
  Future<List<dynamic>> _getBookedSlots() async {
    final supabase = Supabase.instance.client;
    final userId = widget.user[0]['id'].toString();

    final response =
        await supabase.from('booking').select().eq('user_id', userId).execute();

    return response.data as List<dynamic>;
  }

  //* Function to get the turf name for a given turf id from the 'turf' table
  Future<String> _getTurfName(String turfId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('turf')
        .select('turf_name')
        .eq('id', turfId)
        .single()
        .execute();
    return response.data['turf_name'].toString();
  }

  //* Function to get the slot timing for a given slot id from the 'slot' table
  Future<String> _getSlotTiming(String slotId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('slot')
        .select('''startingtime, endingtime, date''')
        .eq('id', slotId)
        .single()
        .execute();

    if (response.data != null) {
      return '${convertDateFormat(response.data['date'])} | ${response.data['startingtime']} - ${response.data['endingtime']}';
    } else {
      return 'Unknown Timing'; // You can modify this message accordingly
    }
  }

  //* Function to navigate to the selected slot
  Future<void> _slotselect(BuildContext context, turfId) async {
    final supabase = Supabase.instance.client;

    //* Fetch slot information from the 'slot' table based on turf id
    final slotResponse = await supabase
        .from('slot')
        .select()
        .eq('turf_id', turfId)
        .eq('status', false)
        .execute();

    final selectedSlot = slotResponse.data as List<dynamic>;

    if (selectedSlot.isNotEmpty) {
      //* If Slots are Available

      //* Navigate to a new page to display the selected slot data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotSelection(
            user: widget.user, // Access user from widget property
            turfData: widget.turfData, // Access turfData from widget property
            selectedSlot: selectedSlot,
          ),
        ),
      );
    } else {
      //* If Slots are not Available
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotIsEmpty(
            user: widget.user, // Access user from widget property
            turfData: widget.turfData, // Access turfData from widget property
            selectedSlot: selectedSlot,
          ),
        ),
      );
    }
  }
}
