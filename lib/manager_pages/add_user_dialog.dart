import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUserDialog extends StatefulWidget {
  final String docId; // Add this field to receive the company ID

  const AddUserDialog({Key? key, required this.docId}) : super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late TextEditingController nameController;
  late TextEditingController telephoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    telephoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  bool _validatePasswords() {
    return passwordController.text == confirmPasswordController.text;
  }

  Future<void> _saveUser() async {
    if (nameController.text.isEmpty ||
        telephoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields.'),
      ));
      return;
    }

    if (!_validatePasswords()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match.'),
      ));
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save user details in Firestore under the company's subcollection
      await FirebaseFirestore.instance.collection('company_users').add({
        'name': nameController.text,
        'telephone': telephoneController.text,
        'email': emailController.text,
        'userId': userCredential.user!.uid,
        'companyUserId': widget.docId,
        'profile': '', // Profile will be added later by the user
        'createdAt': Timestamp.now(),
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add user: $e'),
      ));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New User'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: telephoneController,
              decoration: InputDecoration(labelText: 'Telephone Number'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Company Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        if (isUploading)
          CircularProgressIndicator()
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        const SizedBox(width: 10),
        if (!isUploading)
          ElevatedButton(
            onPressed: _saveUser,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
      ],
    );
  }
}
