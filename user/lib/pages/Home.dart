import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/pages/Login.dart';
import 'package:user/services/api_service.dart';
import 'package:user/widget/call_button.dart';

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
    _userDetails.then((data)=>{
      userName = data["username"]
      
    });
  
   
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      appBar: AppBar(
        title: Text('User App'),
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
                      child:  CallButton(),))),
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
