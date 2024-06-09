import 'package:flutter/material.dart';
import 'package:vihanga_cabs_user_portal/authentication/user_login_screen.dart';
import 'package:vihanga_cabs_user_portal/user_pages/home_page.dart';


class CompanyUserNavBar extends StatelessWidget {
  final String userId;
  final String companyUserId;

  const CompanyUserNavBar({Key? key, required this.userId, required this.companyUserId}) : super(key: key);

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)
    // Navigate to the login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const UserLoginScreen()));
  }


  void _goToNewRideRequestPage(BuildContext context) {
    // Navigate to the new ride request page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NewRideRequest(userId: userId, companyUserId: companyUserId),));
  }

  void _goToOngoingRidesPage(BuildContext context) {
    // Navigate to the ongoing rides page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OngoingRides(userId: userId, companyUserId: companyUserId),));
  }

  void _goToRidesHistoryPage(BuildContext context) {
    // Navigate to the completed rides page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RideHistory(userId: userId, companyUserId: companyUserId),));
  }

  void _goToProfilePage(BuildContext context) {
    // Navigate to the profile page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserProfile(userId: userId, companyUserId: companyUserId),));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/startup.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),

            ListTile(
              leading: Icon(Icons.done),
              title: Text('Ride History'),
              onTap: () => _goToRidesHistoryPage(context),
            ),

            ListTile(
              leading: Icon(Icons.directions_car),
              title: Text('New Ride Request'),
              onTap: () => _goToNewRideRequestPage(context),
            ),
            ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Ongoing Rides'),
              onTap: () => _goToOngoingRidesPage(context),
            ),

            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () => _goToProfilePage(context),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () => _logOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
