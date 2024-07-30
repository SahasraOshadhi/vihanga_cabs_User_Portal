import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/user_ride_history.dart';
import 'package:vihanga_cabs_user_portal/widgets/nav_bar.dart';
import 'add_user_dialog.dart';

class UserDetails extends StatefulWidget {
  final String docId;

  const UserDetails({Key? key, required this.docId}) : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  void initState() {
    super.initState();
    print(widget.docId);
  }

  Future<void> _deleteUser(BuildContext context, QueryDocumentSnapshot user) async {
    try {
      String userId = user['userId'];
      String email = user['email'];

      await FirebaseFirestore.instance.collection('company_users').doc(user.id).delete();

      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteUserByEmail');
      await callable.call(<String, dynamic>{
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Company and associated user deleted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete company: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ManagerNavBar(docId: widget.docId),
      appBar: AppBar(
        title: const Text("User Details"),
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
                  builder: (context) => AddUserDialog(docId: widget.docId),
                );
              },
              child: const Text(
                'Add User',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('company_users').where('companyUserId', isEqualTo: widget.docId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserCard(user: user, deleteUser: _deleteUser);
            },
          );
        },
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final QueryDocumentSnapshot user;
  final Future<void> Function(BuildContext context, QueryDocumentSnapshot user) deleteUser;

  const UserCard({Key? key, required this.user, required this.deleteUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = user.data() as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: userData['profile'] != null && userData['profile'].isNotEmpty
                    ? NetworkImage(userData['profile'])
                    : AssetImage('assets/images/default_profile.jpg') as ImageProvider,
              ),
              SizedBox(height: 10),
              Text(
                userData['name'] ?? 'No Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Email: ${userData['email'] ?? 'No Email'}'),
              SizedBox(height: 10),
              Text('Telephone: ${userData['telephone'] ?? 'No Telephone'}'),
              SizedBox(height: 10),
              Text('Account Created: ${userData['createdAt'] != null ? DateFormat.yMMMd().add_jm().format(userData['createdAt'].toDate()) : 'No Date'}'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideHistoryUser(companyUserId: user.id),
                        ),
                      );
                    },
                    child: Text('Show Ride History'),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await deleteUser(context, user);
                    },
                    child: Text('Delete'),
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
