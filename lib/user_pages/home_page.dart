import 'package:flutter/material.dart';
import 'package:vihanga_cabs_user_portal/widgets/company_user_nav_bar.dart';
import 'package:vihanga_cabs_user_portal/widgets/nav_bar.dart';

class RideHistory extends StatefulWidget {
  final String userId;
  final String companyUserId;
  const RideHistory({super.key, required this.userId, required this.companyUserId});

  @override
  State<RideHistory> createState() => _HomePageState();
}

class _HomePageState extends State<RideHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CompanyUserNavBar(userId: widget.userId, companyUserId: widget.companyUserId,),
      appBar: AppBar(
        title: const Text(
            "Welcome to Vihanga Cabs"
        ),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
