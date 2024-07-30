import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideHistoryUser extends StatefulWidget {
  final String companyUserId;

  const RideHistoryUser({Key? key, required this.companyUserId}) : super(key: key);

  @override
  _RideHistoryUserState createState() => _RideHistoryUserState();
}

class _RideHistoryUserState extends State<RideHistoryUser> {
  late Future<List<RideDetail>> _rideDetailsFuture;

  @override
  void initState() {
    super.initState();
    _rideDetailsFuture = _fetchRideDetails();
    print(widget.companyUserId);
  }

  Future<List<RideDetail>> _fetchRideDetails() async {
    List<RideDetail> rideDetails = [];
    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('cUserId', isEqualTo: widget.companyUserId)
          .get();

      for (var doc in ridesSnapshot.docs) {
        var rideData = doc.data() as Map<String, dynamic>;

        var customerData = await FirebaseFirestore.instance
            .collection('company_users')
            .doc(rideData['cUserId'])
            .get();

        var driverData = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(rideData['driverId'])
            .get();

        var rideReqData = await FirebaseFirestore.instance
            .collection('ride_requests')
            .doc(rideData['rideRequestId'])
            .get();

        rideDetails.add(RideDetail(
          customerName: customerData['name'],
          driverName: "${driverData['firstName']} ${driverData['lastName']}",
          driverContact: driverData['telNum'],
          totalFare: rideData['totalRideFare'],
          rideDate: rideReqData['date'],
          pickup: rideReqData['pickupLocation'],
          destination: rideReqData['destination'],
        ));
      }
    } catch (e) {
      print('Error fetching ride details: $e');
      rethrow;
    }
    return rideDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<List<RideDetail>>(
        future: _rideDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading ride details'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No ride details found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var rideDetail = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer Name: ${rideDetail.customerName}"),
                      SizedBox(height: 5),
                      Text("Driver Name: ${rideDetail.driverName}"),
                      SizedBox(height: 5),
                      Text("Driver Contact: ${rideDetail.driverContact}"),
                      SizedBox(height: 5),
                      Text("Total Fare: ${rideDetail.totalFare}"),
                      SizedBox(height: 5),
                      Text("Ride Date: ${rideDetail.rideDate}"),
                      SizedBox(height: 5),
                      Text("Pickup Location: ${rideDetail.pickup}"),
                      SizedBox(height: 5),
                      Text("Destination: ${rideDetail.destination}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RideDetail {
  final String customerName;
  final String driverName;
  final String driverContact;
  final double totalFare;
  final String rideDate;
  final String pickup;
  final String destination;

  RideDetail({
    required this.customerName,
    required this.driverName,
    required this.driverContact,
    required this.totalFare,
    required this.rideDate,
    required this.pickup,
    required this.destination,
  });
}
