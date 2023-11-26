// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlotMake extends StatefulWidget {
  final int ownerId;
  final List<dynamic> turfData;

  SlotMake({required this.ownerId, required this.turfData});

  @override
  _SlotMakeState createState() => _SlotMakeState();
}

class _SlotMakeState extends State<SlotMake> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _startingTime;
  late TimeOfDay _endingTime;
  int? _selectedTurfId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startingTime = TimeOfDay.now();
    _endingTime = TimeOfDay.now().replacing(hour: _startingTime.hour + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Slot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Select Date',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              TextFormField(
                readOnly: true,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _startingTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _startingTime = pickedTime;
                      _endingTime = pickedTime.replacing(hour: pickedTime.hour + 1);
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Select Starting Time',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a starting time';
                  }
                  return null;
                },
              ),
              TextFormField(
                readOnly: true,
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _endingTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _endingTime = pickedTime;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Select Ending Time',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an ending time';
                  }
                  return null;
                },
              ),
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
              TextButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _createSlot();
                  }
                },
                child: const Text('Make Slot'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createSlot() async {
    // Validate input
    if (_startingTime == null ||
        _endingTime == null ||
        _selectedTurfId == null ||
        _selectedDate == null) {
      // You can show an error message or handle validation as needed
      return;
    }

    final supabase = Supabase.instance.client;

    // Convert time to 'HH:mm' format
    final startingTimeString = DateFormat('HH:mm').format(
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _startingTime.hour, _startingTime.minute),
    );

    final endingTimeString = DateFormat('HH:mm').format(
      DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _endingTime.hour, _endingTime.minute),
    );

    // Insert into the 'slot' table
    final response = await supabase.from('slot').upsert([
      {
        'startingtime': startingTimeString,
        'endingtime': endingTimeString,
        'turf_id': _selectedTurfId,
        'status': false,
        'date': _selectedDate.toLocal().toString().split(' ')[0], // Extracting date in 'yyyy-MM-dd' format
      },
    ]).execute();

    // if (response.error == null) {
      // Slot creation successful
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot booked successfully'),
        ),
      );
    // } 
    // else {
    //   // Handle the error (display error message or take appropriate action)
    //   print('Error creating slot: ${response.error?.message}');
    // }
  }
}
