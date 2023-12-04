// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TurfUpdate extends StatefulWidget {
  final int ownerId;
  final List<dynamic> turfData;

  const TurfUpdate({super.key, required this.ownerId, required this.turfData});

  @override
  // ignore: library_private_types_in_public_api
  _TurfUpdateState createState() => _TurfUpdateState();
}

class _TurfUpdateState extends State<TurfUpdate> {
  int? _selectedTurfId;
  String _newTurfName = '';
  String _newTurfLocation = '';
  String _newTurfPhone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Turf Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedTurfId,
              items: widget.turfData.map((turf) {
                return DropdownMenuItem<int>(
                  value: turf['id'],
                  child: Text(turf['turf_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTurfId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Turf',
              ),
              validator: (value) {
                if (value == null) {
                  return 'Please select a turf';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _newTurfName = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'New Turf Name',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _newTurfLocation = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'New Turf Location',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _newTurfPhone = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'New Turf Phone',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedTurfId != null) {
                  await _updateTurfDetails();
                }
              },
              child: const Text('Update Turf'),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _updateTurfDetails() async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('turf').update({
        'turf_name': _newTurfName,
        'turf_location': _newTurfLocation,
        'turf_phone': int.tryParse(_newTurfPhone) ?? 0,
      }).eq('id', _selectedTurfId).execute();

      // Show a snackbar for a short confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Turf details updated successfully'),
        ),
      );

      // Go back to the previous page and pass data to refresh the state
      Navigator.pop(context, true);
    } catch (error) {
      // Handle errors
      print('Error updating turf details: $error');
    }
  }
}

