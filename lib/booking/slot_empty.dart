import 'package:flutter/material.dart';

class SlotIsEmpty extends StatelessWidget {
  final List<dynamic> user;
  final List<dynamic> turfData;
  final List<dynamic> selectedSlot;

  const SlotIsEmpty({
    super.key,
    required this.user,
    required this.turfData,
    required this.selectedSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Slot Selection'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sorry there is no available slots. ')
          ],
        ),
      ),
    );
  }
}
