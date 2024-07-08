import 'package:customercare/pages/Login.dart';
import 'package:customercare/services/api_service.dart';
import 'package:customercare/widget/call_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage({super.key, required this.email});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _userDetails;

  String? userName;
  void initState() {
    super.initState();

    _userDetails = ApiService().getUserDetails(widget.email);
    _userDetails.then((data) => {userName = data["username"]});
  }

  @override
  Widget build(BuildContext context) {
      bool iscall = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer care App'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _userDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('No user data found');
                } else {
                  final userDetails = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Username: ${userDetails['username']}'),
                      Text('Email: ${userDetails['email']}'),
                      Text('User Type: ${userDetails['userType']}'),
                    ],
                  );
                }
              },
            ),
          ),
          Expanded(
              child: Container(
                  child: Center(

                      child: CallHandler(),
                          )
                          
                          )),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout')),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
