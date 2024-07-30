import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_user_portal/authentication/login_company_manager.dart';
import 'package:vihanga_cabs_user_portal/methods/common_methods.dart';
import 'package:vihanga_cabs_user_portal/user_pages/home_page.dart';
import 'package:vihanga_cabs_user_portal/widgets/loading_dialog.dart';


class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  CommonMethods commonMethods = CommonMethods();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void signInFormValidation() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      commonMethods.displaySnackBar("Fill all fields", context);
    } else {
      signInUser();
    }
  }

  Future<void> signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Please wait..."),
    );

    try {
      final User? userFirebase = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
      ).user;

      if (userFirebase != null) {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('company_users')
            .where('userId', isEqualTo: userFirebase.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String userId = userDoc.id.toString();
          String companyUserId = userData['companyUserId'];

          if (userData['email'] == _emailController.text.trim()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => RideHistory(userId: userId, companyUserId: companyUserId)),
              ).then((value) {
                print("Navigation completed.");
              }).catchError((error) {
                print("Navigation error: $error");
              });
            });
          } else {
            FirebaseAuth.instance.signOut();
            commonMethods.displaySnackBar("No user record found. Please contact support.", context);
          }
        } else {
          FirebaseAuth.instance.signOut();
          commonMethods.displaySnackBar("No user record found. Please contact support.", context);
        }
      }
    } catch (error) {
      Navigator.pop(context); // Dismiss the loading dialog
      commonMethods.displaySnackBar(error.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManagerLoginScreen()),
                );
              },
              icon: Icon(Icons.manage_accounts, size: 25,),
              color: Colors.deepPurpleAccent)
        ],
      ),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/startup.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login as a User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: !_passwordVisible,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: signInFormValidation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
