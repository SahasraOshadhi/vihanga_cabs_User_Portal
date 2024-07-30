import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_user_portal/widgets/company_user_nav_bar.dart';

class OngoingRides extends StatefulWidget {
  final String userId;
  final String companyUserId;

  const OngoingRides({Key? key, required this.userId, required this.companyUserId}) : super(key: key);

  @override
  _OngoingRidesState createState() => _OngoingRidesState();
}

class _OngoingRidesState extends State<OngoingRides> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanyUserNavBar(userId: widget.userId, companyUserId: widget.companyUserId),
      appBar: AppBar(
        title: const Text('Ongoing Rides'),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_requests')
            .where('userId', isEqualTo: widget.userId)
            .where('companyUserId', isEqualTo: widget.companyUserId)
            .where('acceptedByDriver', isEqualTo: 'yes') // Only show assigned requests
            .where('rideCompletedByUser', isEqualTo: 'no') // Only show requests not completed by the user
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final ongoingRides = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ongoingRides.length,
            itemBuilder: (context, index) {
              final rideRequest = ongoingRides[index];
              return OngoingRideCard(
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

class OngoingRideCard extends StatelessWidget {
  final QueryDocumentSnapshot rideRequest;
  final String userId;
  final String companyUserId;

  const OngoingRideCard({
    Key? key,
    required this.rideRequest,
    required this.userId,
    required this.companyUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideRequestData = rideRequest.data() as Map<String, dynamic>;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ride_requests')
          .doc(rideRequest.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final updatedRideRequestData = snapshot.data!.data() as Map<String, dynamic>?;

        if (updatedRideRequestData == null) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("Invalid ride request data."),
            ),
          );
        }

        final rideStarted = updatedRideRequestData['rideStarted'] == 'yes';
        final rideCompletedByDriver = updatedRideRequestData['rideCompletedByDriver'] == 'yes';
        final statusText = rideCompletedByDriver ? 'Complete' : (rideStarted ? 'Ongoing' : 'Accepted');
        final statusColor = rideCompletedByDriver ? Colors.amber : (rideStarted ? Colors.green : Colors.white);

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchDriverData(rideRequestData['assignedDriver'] ?? ''),
          builder: (context, driverSnapshot) {
            if (!driverSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final driverData = driverSnapshot.data!;

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
                      if (rideRequestData['stop1'] != null && rideRequestData['stop1'].isNotEmpty)
                        Text('Stop 1: ${rideRequestData['stop1']}'),
                      SizedBox(height: 10),
                      if (rideRequestData['stop2'] != null && rideRequestData['stop2'].isNotEmpty)
                        Text('Stop 2: ${rideRequestData['stop2']}'),
                      SizedBox(height: 10),
                      Text('No of Passengers: ${rideRequestData['passengers'] ?? 'No Passengers'}'),
                      SizedBox(height: 20),
                      Text('Driver Name: ${driverData['firstName'] ?? 'N/A'} ${driverData['lastName'] ?? 'N/A'}'),
                      SizedBox(height: 10),
                      Text('Driver Contact: ${driverData['telNum'] ?? 'N/A'}'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: rideCompletedByDriver
                                ? () => _completeRide(context, rideRequest.id)
                                : null,
                            child: Text(statusText),
                            style: ElevatedButton.styleFrom(
                              primary: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchDriverData(String driverId) async {
    if (driverId.isEmpty) return {};
    DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance.collection('drivers').doc(driverId).get();
    return driverSnapshot.data() as Map<String, dynamic>? ?? {};
  }

  Future<void> _completeRide(BuildContext context, String rideRequestId) async {
    await FirebaseFirestore.instance.collection('ride_requests').doc(rideRequestId).update({
      'rideCompletedByUser': 'yes',
    });
    // Force the parent widget to rebuild and refresh the list
    (context as Element).reassemble();
  }
}
