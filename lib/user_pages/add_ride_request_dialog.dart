import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRideRequestDialog extends StatefulWidget {
  final String userId;
  final String companyUserId;

  const AddRideRequestDialog({Key? key, required this.userId, required this.companyUserId}) : super(key: key);

  @override
  _AddRideRequestDialogState createState() => _AddRideRequestDialogState();
}

class _AddRideRequestDialogState extends State<AddRideRequestDialog> {
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController pickupLocationController;
  late TextEditingController destinationController;
  late TextEditingController stop1Controller;
  late TextEditingController stop2Controller;
  late TextEditingController passengersController;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController();
    timeController = TextEditingController();
    pickupLocationController = TextEditingController();
    destinationController = TextEditingController();
    stop1Controller = TextEditingController();
    stop2Controller = TextEditingController();
    passengersController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveRideRequest() async {
    if (dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        pickupLocationController.text.isEmpty ||
        destinationController.text.isEmpty ||
        passengersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all mandatory fields.')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('ride_requests').add({
        'userId': widget.userId,
        'companyUserId': widget.companyUserId,
        'date': dateController.text,
        'time': timeController.text,
        'pickupLocation': pickupLocationController.text,
        'destination': destinationController.text,
        'stop1': stop1Controller.text,
        'stop2': stop2Controller.text,
        'passengers': int.parse(passengersController.text),
        'createdAt': Timestamp.now(),
        'assigned': "no",
        'acceptedByDriver': "notyet",
        'rideStarted' : "no",
        'rideCompletedByDriver' : "no",
        'rideCompletedByUser' : "no",
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add ride request: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Ride Request'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pickupLocationController,
              decoration: const InputDecoration(labelText: 'Pickup Location'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: destinationController,
              decoration: const InputDecoration(labelText: 'Destination'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: stop1Controller,
              decoration: const InputDecoration(labelText: 'Stop 1 (Optional)'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: stop2Controller,
              decoration: const InputDecoration(labelText: 'Stop 2 (Optional)'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passengersController,
              decoration: const InputDecoration(labelText: 'No of Passengers'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        if (isUploading)
          const CircularProgressIndicator()
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        const SizedBox(width: 10),
        if (!isUploading)
          ElevatedButton(
            onPressed: _saveRideRequest,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
      ],
    );
  }
}
