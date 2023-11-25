import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turf/booking/slot_select.dart';
import 'package:turf/booking/slot_empty.dart';

class TurfSelect extends StatelessWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;

  const TurfSelect({super.key, required this.user, required this.turfData});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _slotselect(BuildContext context, turfId) async {
    final supabase = Supabase.instance.client;

    //* Fetch slot information from the 'slot' table based on turf id
    final slotResponse = await supabase
        .from('slot')
        .select()
        .eq('turf_id', turfId)
        .eq('status', false) //* Add condition for the 'status' column
        // ignore: deprecated_member_use
        .execute();

    final selectedSlot = slotResponse.data as List<dynamic>;

    selectedSlot.isNotEmpty ? //* If Slots are Available

      //* Navigate to a new page to display the selected slot data
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotSelection(
            user: user,
            turfData: turfData,
            selectedSlot: selectedSlot,
          ),
        ),
      )
     : 
      //* If Slots are not Available
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SlotIsEmpty(
            user: user,
            turfData: turfData,
            selectedSlot: selectedSlot,
          ),
        ),
      ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turf Select'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user[0]['fname']} ${user[0]['lname']}!'),
            const SizedBox(height: 20),
            const Text('List of Turfs:'),
            Expanded(
              child: ListView.builder(
                itemCount: turfData.length,
                itemBuilder: (context, index) {
                  final turf = turfData[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}


