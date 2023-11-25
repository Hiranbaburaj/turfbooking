// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/booking/slot_select.dart';
import 'package:turf/booking/slot_empty.dart';

class TurfSelect extends StatefulWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;

  const TurfSelect({super.key, required this.user, required this.turfData});

  @override
  // ignore: library_private_types_in_public_api
  _TurfSelectState createState() => _TurfSelectState();
}

class _TurfSelectState extends State<TurfSelect> {
  int _selectedIndex = 0; // Index for the selected bottom navigation bar item
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
        title: const Text(
          'Turf Select',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 20.0, // Set font size to 24.0
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
        backgroundColor: const Color(0xFF71DE95),
      ),
      body: _selectedIndex ==
              0 // * Display available slots or booked slots based on the selected tab
          ? _buildAvailableSlots() // * Function to build the available slots view
          : _buildBookedSlots(), // * Function to build the booked slots view
      bottomNavigationBar: BottomNavigationBar(
        // Background color for the entire BottomNavigationBar
        backgroundColor: const Color.fromARGB(255, 71, 222, 149),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Available Slots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_busy),
            label: 'Booked Slots',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(
            255, 118, 81, 179), // Text and icon color when selected
        unselectedItemColor:
            Colors.white, // Text and icon color when unselected
        onTap: _onItemTapped,
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
          Text(
            'Welcome, ${widget.user[0]['fname']} ${widget.user[0]['lname']}!',
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select City:'),

          // DropdownButton for selecting cities
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
                      child: Text(cityName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                    });
                  },
                  hint: const Text('Select City'), // Placeholder text
                );
              }
            },
          ),

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

                  return ListView.builder(
                    itemCount: filteredTurfData.length,
                    itemBuilder: (context, index) {
                      final turf = filteredTurfData[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                                '${turf['turf_name']} - ${turf['turf_location']}'),
                            subtitle: Text(
                                'Owner: ${turf['owner_name']}, Phone: ${turf['turf_phone']}'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _slotselect(context, turf['id']);
                            },
                            child: const Text('Book Slots Now'),
                          ),
                        ],
                      );
                    },
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
                            future: _getTurfName(bookedSlot['turf_id'].toString()),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
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
                                future: _getSlotTiming(bookedSlot['slot_id'].toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return const Text('Error loading slot timing');
                                  } else {
                                    final timing = snapshot.data as String;
                                    return Text('Timing: $timing');
                                  }
                                },
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
