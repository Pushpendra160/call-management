import 'package:customercare/pages/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WebRTC.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' customer care',
      theme: ThemeData(
    
        
      ),
      home: LoginPage()
    );
  }
}

