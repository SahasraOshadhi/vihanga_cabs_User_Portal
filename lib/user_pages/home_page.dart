import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_user_portal/widgets/company_user_nav_bar.dart';
import 'package:vihanga_cabs_user_portal/widgets/profile_header.dart';

class RideHistory extends StatefulWidget {
  final String userId;
  final String companyUserId;
  const RideHistory({super.key, required this.userId, required this.companyUserId});

  @override
  State<RideHistory> createState() => _RideHistoryState();
}

class _RideHistoryState extends State<RideHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('company_users').doc(widget.userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      final String name = data['name'] ?? '';
      final String email = data['email'] ?? '';
      final String imageUrl = data['profilePic'] ?? '';

      print(userDoc.id);

      return {
        'name': name,
        'email': email,
        'imageUrl': imageUrl,
      };
    } else {
      print('No user data found for the provided company user ID.');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      drawer: CompanyUserNavBar(userId: widget.userId, companyUserId: widget.companyUserId),
      appBar: AppBar(
        title: const Text('Welcome to Vihanga Cabs'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching user data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No user data available'));
            } else {
              final userData = snapshot.data!;
              final String name = userData['name'];
              final String email = userData['email'];
              final String imageUrl = userData['imageUrl'].isNotEmpty
                  ? userData['imageUrl']
                  : 'assets/images/default_profile.jpg';

              return Column(
                children: [
                  const SizedBox(height: 8),
                  ProfileHeader(
                    name: name,
                    email: email,
                    imageUrl: imageUrl,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ride_requests')
                          .where('userId', isEqualTo: widget.userId)
                          .where('companyUserId', isEqualTo: widget.companyUserId)
                          .where('rideCompletedByUser', isEqualTo: 'yes')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final completedRides = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: completedRides.length,
                          itemBuilder: (context, index) {
                            final rideRequest = completedRides[index];
                            return CompletedRideCard(
                              rideRequest: rideRequest,
                              userId: widget.userId,
                              companyUserId: widget.companyUserId,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class CompletedRideCard extends StatelessWidget {
  final QueryDocumentSnapshot rideRequest;
  final String userId;
  final String companyUserId;

  const CompletedRideCard({
    Key? key,
    required this.rideRequest,
    required this.userId,
    required this.companyUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rideRequestData = rideRequest.data() as Map<String, dynamic>;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('ride_requests')
          .doc(rideRequest.id)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final updatedRideRequestData = snapshot.data!.data() as Map<String, dynamic>?;

        if (updatedRideRequestData == null) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const Text("Invalid ride request data."),
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
              return const Center(child: CircularProgressIndicator());
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
}
