import 'package:flutter/material.dart';

class ViewAnalysisResultScreen extends StatelessWidget {
  final String result;

  ViewAnalysisResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Analysis Result'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          result,
          style: TextStyle(fontSize: 8.0),
        ),
      ),
    );
  }
}