import 'package:flutter/material.dart';

class CallingScreen extends StatelessWidget {
  final VoidCallback onEndCall;

  CallingScreen({required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calling'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Calling...',
              style: TextStyle(fontSize: 24),
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
