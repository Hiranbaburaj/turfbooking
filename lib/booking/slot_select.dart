import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

                  // * Parse the slot date and time in IST (Indian Standard Time)
                  final slotDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .parse('${slot['date']} ${slot['startingtime']} IST');

                  // * Check if the slot date is the current date or later in IST
                  if (slotDateTime.isAfter(
                      DateTime.now().toUtc().subtract(const Duration(hours: 12)))) {
                    final turfId = slot['turf_id'];

                    //* Find the corresponding turf data based on turf_id
                    final matchingTurf = turfData.firstWhere(
                      (turf) => turf['id'] == turfId,
                      orElse: () => null,
                    );

                    return Column(
                      children: [
                        ListTile(
                          title: Text(convertDateFormat(slot['date'])),
                          subtitle: Text(
                              '${slot['startingtime']} - ${slot['endingtime']}'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //* Insert a new row into the 'booking' table
                            _bookSlot(
                                context,
                                matchingTurf['id'].toString(),
                                slot['id'].toString(),
                                user[0]['id'].toString());
                          },
                          child: const Text('Book Slot'),
                        ),
                      ],
                    );
                  } else {
                    // Return an empty container for slots on previous dates
                    return Container();
                  }
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
    try {
      // ignore: unused_local_variable
      final response = await supabase.from('booking').upsert([
        {
          'turf_id': turfId,
          'slot_id': slotId,
          'user_id': userId,
        },
      ]);
      await supabase
          .from('slot')
          .update({'status': true}).match({'id': slotId});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot booked successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error booking the slot'),
        ),
      );
    }
    //* Returns to the turf_select page after booking
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
