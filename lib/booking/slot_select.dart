import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlotSelection extends StatelessWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;
  final List<dynamic> selectedSlot;

  const SlotSelection({
    super.key,
    required this.user,
    required this.turfData,
    required this.selectedSlot,
  });

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    //* Use turfData to find the matching turf for the first selected slot
    final matchTurf = turfData.firstWhere(
      (turf) => turf['id'] == selectedSlot[0]['turf_id'],
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        //* Display the turf name for the first selected slot
        title: Text(
          'Slot Selection - ${matchTurf != null ? matchTurf['turf_name'] : ''}',
          style: const TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 20.0, // Set font size to 24.0
          ),
        ),
        backgroundColor: const Color(0xFF71DE95),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: selectedSlot.length,
                itemBuilder: (context, index) {
                  final slot = selectedSlot[index];
                  final turfId = slot['turf_id'];

                  //* Find the corresponding turf data based on turf_id
                  final matchingTurf = turfData.firstWhere(
                    (turf) => turf['id'] == turfId,
                    orElse: () => null,
                  );

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                            convertDateFormat(slot['date'])),
                        subtitle: Text(
                            '${slot['startingtime']} - ${slot['endingtime']}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          //* Insert a new row into the 'booking' table
                          _bookSlot(context, matchingTurf['id'].toString(),
                              slot['id'].toString(), user[0]['id'].toString());
                        },
                        child: const Text('Book Slot'),
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

  //* Function to convert date
  String convertDateFormat(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year.toString()}";
    return formattedDate;
  }

  //* Function to book a slot by inserting a row into the 'booking' table
  Future<void> _bookSlot(
      BuildContext context, String turfId, String slotId, String userId) async {
    final supabase = Supabase.instance.client;

    //* Print the values to the debug console
    // ignore: avoid_print
    print('Booking Slot - turfId: $turfId, slotId: $slotId, userId: $userId');

    //* Insert a new row into the 'booking' table
    // ignore: unused_local_variable
    final response = await supabase.from('booking').upsert([
      {
        'turf_id': turfId,
        'slot_id': slotId,
        'user_id': userId,
      },
      // ignore: deprecated_member_use
    ]).execute();

    await supabase.from('slot').update({'status': true}).match({'id': slotId});

    // if (response.error == null) {
    // Booking successful
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Slot booked successfully'),
      ),
    );
    // } else {
    //   // Handle error if needed
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Error booking the slot'),
    //     ),
    //   );
    // }

    //* Returns to the turf_select page after booking
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
