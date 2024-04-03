import 'package:flutter/material.dart';



class AnalysisItem extends StatelessWidget {
  final String doctorName;
  final String message;
  final String date;

  AnalysisItem({
    required this.doctorName,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple, // Az ikon háttérszíne
          child: Icon(Icons.analytics, color: Colors.white), // Az ikon színe
        ),
        title: Text(
          doctorName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          // Itt kell majd navigálni az AnalysisResponseScreen-re
        },
      ),
    );
  }
}
