import 'package:flutter/material.dart';
import 'package:vihanga_cabs_user_portal/authentication/user_login_screen.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/manager_home_page.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/ride_history.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/user_details.dart';


class ManagerNavBar extends StatelessWidget {
  final String docId;

  const ManagerNavBar({Key? key, required this.docId}) : super(key: key);

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)
    // Navigate to the login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const UserLoginScreen()));
  }

  void _goToDashboardPage(BuildContext context) {
    // Navigate to the dashboard page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePageManager(docId: docId,)));
  }

  void _goToUserDetailsPage(BuildContext context) {
    // Navigate to the user details page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserDetails(docId: docId,)));
  }

  void _goToRideHistoryPage(BuildContext context) {
    // Navigate to the user details page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RideHistoryCompany(docId: docId,)));
  }

  void _goToProfilePage(BuildContext context) {
    // Navigate to the profile page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Profile()));
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
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => _goToDashboardPage(context),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text('User Details'),
              onTap: () => _goToUserDetailsPage(context),
            ),

            ListTile(
              leading: Icon(Icons.done),
              title: Text('Ride History'),
              onTap: () => _goToRideHistoryPage(context),
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

