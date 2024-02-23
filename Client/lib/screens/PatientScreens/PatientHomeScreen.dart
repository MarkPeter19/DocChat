import 'package:flutter/material.dart';
import '/screens/PatientScreens/PersonalDataScreen.dart';

class PatientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 550),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PersonalDataScreen()),
              ),
              child: Text('New Analysis'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic for navigating to Add Doctor screen
              },
              child: Text('Add Doctor'),
            ),
          ],
        ),
      ),
    );
  }
}
