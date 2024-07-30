import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_user_portal/widgets/company_user_nav_bar.dart';
import 'package:vihanga_cabs_user_portal/user_pages/add_ride_request_dialog.dart';

class RideRequestDetails extends StatefulWidget {
  final String userId;
  final String companyUserId;

  const RideRequestDetails({Key? key, required this.userId, required this.companyUserId}) : super(key: key);

  @override
  _RideRequestDetailsState createState() => _RideRequestDetailsState();
}

class _RideRequestDetailsState extends State<RideRequestDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanyUserNavBar(userId: widget.userId, companyUserId: widget.companyUserId),
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.amber,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent, // Button color
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddRideRequestDialog(userId: widget.userId, companyUserId: widget.companyUserId),
                );
              },
              child: const Text(
                'New Ride Request',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_requests')
            .where('userId', isEqualTo: widget.userId)
            .where('companyUserId', isEqualTo: widget.companyUserId)
            .where('assigned', isEqualTo: 'no') // Only show unassigned requests
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final rideRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rideRequests.length,
            itemBuilder: (context, index) {
              final rideRequest = rideRequests[index];
              return RideRequestCard(
                rideRequest: rideRequest,
                userId: widget.userId,
                companyUserId: widget.companyUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class RideRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot rideRequest;
  final String userId;
  final String companyUserId;

  const RideRequestCard({
    Key? key,
    required this.rideRequest,
    required this.userId,
    required this.companyUserId,
  }) : super(key: key);

  Future<void> _deleteRideRequest(BuildContext context, QueryDocumentSnapshot rideRequest) async {
    try {
      await FirebaseFirestore.instance.collection('ride_requests').doc(rideRequest.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride request deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete ride request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestData = rideRequest.data() as Map<String, dynamic>;
    final isAssigned = rideRequestData['assigned'] == 'no';
    final isAcceptedByDriver = rideRequestData['acceptedByDriver'] == 'yes';

    // Do not display the card if the request has been accepted by the driver
    if (isAcceptedByDriver) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: ${rideRequestData['date'] ?? 'No Date'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Time: ${rideRequestData['time'] ?? 'No Time'}'),
              SizedBox(height: 10),
              Text('Pickup Location: ${rideRequestData['pickupLocation'] ?? 'No Pickup Location'}'),
              SizedBox(height: 10),
              Text('Destination: ${rideRequestData['destination'] ?? 'No Destination'}'),
              SizedBox(height: 10),
              Text('No of Passengers: ${rideRequestData['passengers'] ?? 'No Passengers'}'),
              SizedBox(height: 10),
              if (rideRequestData['stop1'] != null && rideRequestData['stop1'].isNotEmpty)
                Text('Stop 1: ${rideRequestData['stop1']}'),
              SizedBox(height: 10),
              if (rideRequestData['stop2'] != null && rideRequestData['stop2'].isNotEmpty)
                Text('Stop 2: ${rideRequestData['stop2']}'),
              SizedBox(height: 20),
              if (isAssigned) // Show delete button only if the request is not assigned
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _deleteRideRequest(context, rideRequest);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
