import 'package:flutter/material.dart';
import 'package:vihanga_cabs_user_portal/widgets/nav_bar.dart';


class HomePageManager extends StatefulWidget {
  final String docId;

  const HomePageManager({Key? key, required this.docId}) : super(key: key);

  @override
  State<HomePageManager> createState() => _HomePageState();
}

class _HomePageState extends State<HomePageManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ManagerNavBar(docId: widget.docId,),
      appBar: AppBar(
        title: const Text(
            "Welcome to Vihanga Cabs"
        ),
        backgroundColor: Colors.amber,
      ),
    );
  }
}
