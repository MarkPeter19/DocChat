import 'package:flutter/material.dart';
import '../screens/DoctorScreens/Requests/PatientDataDetailsScreen.dart';

class PatientRequestItem extends StatelessWidget {
  final String patientName;
  final String documentDate;
  final String documentId;
  final String patientId;

  PatientRequestItem({
    required this.patientName,
    required this.documentDate,
    required this.documentId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Color.fromARGB(255, 240, 250, 255),
      elevation: 5.0,
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(patientName[0],
                style:
                    TextStyle(fontSize: 18)), // A páciens nevének első betűje
            foregroundColor: Colors.white,
            radius: 25,
          ),
          title: Text(
            patientName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            documentDate,
            style: TextStyle(fontSize: 16),
          ), // A dokumentum feltöltési idejének megjelenítése
          trailing: Icon(Icons.keyboard_arrow_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PatientDataDetailsScreen(
                  patientId: patientId,
                  documentId: documentId,
                ),
              ),
            );
          }),
    );
  }
}
