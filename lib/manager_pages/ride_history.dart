import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_user_portal/widgets/nav_bar.dart';

class RideHistoryCompany extends StatefulWidget {
  final String docId;
  const RideHistoryCompany({super.key, required this.docId});

  @override
  State<RideHistoryCompany> createState() => _RideHistoryCompanyState();
}

class _RideHistoryCompanyState extends State<RideHistoryCompany> {
  late Future<List<RideDetail>> _rideDetailsFuture;
  double _totalFare = 0.0;

  @override
  void initState() {
    super.initState();
    _rideDetailsFuture = _fetchRideDetails();
    print(widget.docId);
  }

  Future<List<RideDetail>> _fetchRideDetails() async {
    List<RideDetail> rideDetails = [];
    double totalFare = 0.0;

    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('companyId', isEqualTo: widget.docId)
          .get();

      for (var doc in ridesSnapshot.docs) {
        print('Ride Document ID: ${doc.id}');
        var rideData = doc.data() as Map<String, dynamic>;
        print('Ride Data: $rideData');

        var customerData = await FirebaseFirestore.instance
            .collection('company_users')
            .doc(rideData['cUserId'])
            .get();
        print('Customer Data: ${customerData.data()}');

        var driverData = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(rideData['driverId'])
            .get();
        print('Driver Data: ${driverData.data()}');

        var rideReqData = await FirebaseFirestore.instance
            .collection('ride_requests')
            .doc(rideData['rideRequestId'])
            .get();
        print('Ride Request Data: ${rideReqData.data()}');

        double rideFare = rideData['totalRideFare'];
        totalFare += rideFare;

        rideDetails.add(RideDetail(
          customerName: customerData['name'],
          driverName: "${driverData['firstName']} ${driverData['lastName']}",
          driverContact: driverData['telNum'],
          totalFare: rideFare,
          rideDate: rideReqData['date'],
          pickup: rideReqData['pickupLocation'],
          destination: rideReqData['destination'],
        ));
      }

      setState(() {
        _totalFare = totalFare;
      });

      print('Total Rides Fetched: ${rideDetails.length}');
      if (rideDetails.isNotEmpty) {
        print('First Ride Customer Name: ${rideDetails.first.customerName}');
      }
    } catch (e) {
      print('Error fetching ride details: $e');
      rethrow; // Rethrow the error to be caught by the FutureBuilder
    }
    return rideDetails;
  }

  Future<void> _clearRideDetails() async {
    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('companyId', isEqualTo: widget.docId)
          .get();

      for (var doc in ridesSnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _totalFare = 0.0;
        _rideDetailsFuture = _fetchRideDetails();
      });
    } catch (e) {
      print('Error clearing ride details: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ManagerNavBar(docId: widget.docId,),
      appBar: AppBar(
        title: Text('Ride History'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    'Total Amount to Pay: Rs. ${_totalFare.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _clearRideDetails();
                  },
                  child: Text('Paid'),
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RideDetail>>(
              future: _rideDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('FutureBuilder Error: ${snapshot.error}');
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
                            Text("Total Fare: Rs. ${rideDetail.totalFare.toStringAsFixed(2)}"),
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
          ),
        ],
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
