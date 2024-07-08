import 'package:flutter/material.dart';

class CallingScreen extends StatelessWidget {
  final VoidCallback onEndCall;

  const CallingScreen({Key? key, required this.onEndCall}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calling Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Call in progress...',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onEndCall,
              child: Text('End Call'),
            ),
          ],
        ),
      ),
    );
  }
}
