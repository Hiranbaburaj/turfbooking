import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewPastBookings extends StatelessWidget {
  final List<dynamic> user;

  const ViewPastBookings({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Bookings'),
      ),
      body: FutureBuilder(
        future: _getPastBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error loading past bookings: ${snapshot.error}'));
          } else {
            final pastBookings = snapshot.data as List<Map<String, dynamic>>;

            if (pastBookings.isEmpty) {
              return const Center(child: Text('No past bookings available'));
            }

            return ListView.builder(
              itemCount: pastBookings.length,
              itemBuilder: (context, index) {
                final booking = pastBookings[index];

                return ListTile(
                  title: Text('Booking ID: ${booking['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Turf Name: ${booking['turf_name']}'),
                      Text('Turf Location: ${booking['turf_location']}'),
                      Text('Slot Date: ${booking['date']}'),
                      Text('Starting Time: ${booking['startingtime']}'),
                      Text('Ending Time: ${booking['endingtime']}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPastBookings() async {
    final supabase = Supabase.instance.client;

    try {
      final currentDate = DateTime.now().toLocal();
      final response = await supabase
          .from('booking')
          .select('id, turf_id, slot_id, user_id')
          .eq('user_id', user[0]['id'])
          .execute();

      final bookingData = response.data as List;
      final pastBookings = <Map<String, dynamic>>[];

      for (final booking in bookingData) {
        // Retrieve turf information
        final turfResponse = await supabase
            .from('turf')
            .select('turf_name, turf_location')
            .eq('id', booking['turf_id'])
            .single()
            .execute();

        final turfData = turfResponse.data;

        // Retrieve slot information
        final slotResponse = await supabase
            .from('slot')
            .select('date, startingtime, endingtime')
            .eq('id', booking['slot_id'])
            .single()
            .execute();

        final slotData = slotResponse.data;

        // Check if the Slot Date is before the current date
        if (slotData?['date'] != null &&
            DateTime.parse(slotData!['date']).isBefore(currentDate)) {
          // Combine booking, turf, and slot information
          final pastBooking = <String, dynamic>{
            'id': booking['id'],
            'turf_name': turfData?['turf_name'],
            'turf_location': turfData?['turf_location'],
            'date': slotData?['date'],
            'startingtime': slotData?['startingtime'],
            'endingtime': slotData?['endingtime'],
          };

          pastBookings.add(pastBooking);
        }
      }

      return pastBookings;
    } catch (error) {
      rethrow;
    }
  }
}
