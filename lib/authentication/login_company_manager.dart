import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/manager_home_page.dart';
import 'package:vihanga_cabs_user_portal/manager_pages/ride_history.dart';
import 'package:vihanga_cabs_user_portal/methods/common_methods.dart';
import 'package:vihanga_cabs_user_portal/widgets/loading_dialog.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen> {
  CommonMethods commonMethods = CommonMethods();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void signInFormValidation() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      commonMethods.displaySnackBar("Fill all fields", context);
    } else {
      signInManager();
    }
  }

  Future<void> signInManager() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Please wait..."),
    );

    try {
      print("Signing in manager...");
      final User? managerFirebase = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
      ).user;

      if (managerFirebase != null) {
        print("Signed in successfully, fetching company details...");
        QuerySnapshot companySnapshot = await FirebaseFirestore.instance
            .collection('companies')
            .where('userId', isEqualTo: managerFirebase.uid)
            .get();

        print(companySnapshot.docs.first.id);

        if (companySnapshot.docs.isNotEmpty) {
          DocumentSnapshot companyDoc = companySnapshot.docs.first;
          Map<String, dynamic> companyData = companyDoc.data() as Map<String, dynamic>;

          print(companyData['email']);
          print(companyDoc.id);
          String docId = companyDoc.id.toString();

          print("Company found, checking manager email...");
          if (companyData['email'] == _emailController.text.trim()) {
            print("Manager email matches, navigating to HomePageManager...");

            // Simplified navigation call
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (c) => RideHistoryCompany(docId: docId)
                ),
              ).then((value) {
                print("Navigation completed.");
              }).catchError((error) {
                print("Navigation error: $error");
              });
            });

            print("Navigation to HomePageManager should have occurred.");
          } else {
            print("Manager email does not match.");
            FirebaseAuth.instance.signOut();
            commonMethods.displaySnackBar("No record found. Please contact support.", context);
          }
        } else {
          print("No company record found.");
          FirebaseAuth.instance.signOut();
          commonMethods.displaySnackBar("No company record found. Please contact support.", context);
        }
      } else {
        print("Failed to sign in.");
        commonMethods.displaySnackBar("Failed to sign in. Please try again.", context);
      }
    } catch (error) {
      print("Error: $error");
      commonMethods.displaySnackBar(error.toString(), context);
    } finally {
      Navigator.pop(context); // Dismiss the loading dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Login as a Manager',
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
