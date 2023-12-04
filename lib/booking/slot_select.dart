import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SlotSelection extends StatefulWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;
  final List<dynamic> selectedSlot;

  const SlotSelection({
    super.key,
    required this.user,
    required this.turfData,
    required this.selectedSlot,
  });

  @override
  State<SlotSelection> createState() => _SlotSelectionState();
}

class _SlotSelectionState extends State<SlotSelection> {
  Razorpay? _razorpay;

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS PAYMENT: ${response.paymentId}", timeInSecForIosWeb: 4);

    // Retrieve turfId, slotId, and userId from SharedPreferences
    retrieveSlotInfo().then((Map<String, String> values) {
      String turfId = values['turfId'] ?? '';
      String slotId = values['slotId'] ?? '';
      String userId = values['userId'] ?? '';

      // Call _bookSlot() function after successful payment
      _bookSlot(context, turfId, slotId, userId);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR HERE: ${response.code} - ${response.message}",
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET IS : ${response.walletName}",
        timeInSecForIosWeb: 4);
  }

  void openPaymentPortal() async {
    // Extract turfId from selectedSlot
    final turfId = widget.selectedSlot[0]['turf_id'].toString();

    // Fetch the 'turf' row from the table
    final turfResponse = await Supabase.instance.client
        .from('turf')
        .select('owner_id')
        .eq('id', turfId)
        .single()
        .execute();

    if (turfResponse.data != null) {
      final ownerId = turfResponse.data!['owner_id'].toString();
      print('Owner ID: $ownerId');
      // Remove shared preferences before proceeding
      await removeSlotInfo();

      // Save turfId, slotId, and userId to shared preferences
      final slotId = widget.selectedSlot[0]['id'].toString();
      final userId = widget.user[0]['id'].toString();
      await saveSlotInfo(turfId, slotId, userId);

      // Fetch owner details from 'turf_owner' table
      final ownerResponse = await Supabase.instance.client
          .from('turf_owner')
          .select()
          .eq('id', ownerId)
          .execute();

      if (ownerResponse.data != null && ownerResponse.data!.length > 0) {
        final ownerData = ownerResponse.data![0];

        var options = {
          'key': 'rzp_test_QshKjoFtlmmRpF',
          'amount': 70000,
          'name': '${ownerData['f_name']} ${ownerData['l_name']}', // Owner name
          'description': 'Payment',
          'prefill': {
            'contact': ownerData['phone'], // Owner phone
            'email': ownerData['mail'], // Owner email
          },
          'external': {
            'wallets': ['paytm']
          }
        };

        try {
          _razorpay?.open(options);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  // @override
  // BuildContext? get context => null;
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    //* Use turfData to find the matching turf for the first selected slot
    final matchTurf = widget.turfData.firstWhere(
      (turf) => turf['id'] == widget.selectedSlot[0]['turf_id'],
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
                itemCount: widget.selectedSlot.length,
                itemBuilder: (context, index) {
                  final slot = widget.selectedSlot[index];

                  // * Parse the slot date and time in IST (Indian Standard Time)
                  final slotDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
                      .parse('${slot['date']} ${slot['startingtime']} IST');

                  // * Check if the slot date is the current date or later in IST
                  if (slotDateTime.isAfter(DateTime.now()
                      .toUtc()
                      .subtract(const Duration(hours: 12)))) {
                    final turfId = slot['turf_id'];

                    //* Find the corresponding turf data based on turf_id
                    final matchingTurf = widget.turfData.firstWhere(
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
                            openPaymentPortal();
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

  Future<void> saveSlotInfo(String turfId, String slotId, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('turfId', turfId);
    prefs.setString('slotId', slotId);
    prefs.setString('userId', userId);
  }

  Future<Map<String, String>> retrieveSlotInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String turfId = prefs.getString('turfId') ?? '';
    String slotId = prefs.getString('slotId') ?? '';
    String userId = prefs.getString('userId') ?? '';

    return {
      'turfId': turfId,
      'slotId': slotId,
      'userId': userId,
    };
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

      // Remove shared preferences after booking
      await removeSlotInfo();
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

  Future<void> removeSlotInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('turfId');
    prefs.remove('slotId');
    prefs.remove('userId');
  }
}
