import 'package:flutter/material.dart';

class PatientChatPDFScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask ChatPDF AI'),
      ),
      body: Center(
        child: Text(
          'Patient ChatPDF',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
