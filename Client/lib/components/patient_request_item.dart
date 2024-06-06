import 'package:flutter/material.dart';
import '../screens/DoctorScreens/Requests/PatientDataDetailsScreen.dart';

class PatientRequestItem extends StatelessWidget {
  final String patientName;
  final String documentDate;
  final String documentId;
  final String patientId;

  const PatientRequestItem({
    super.key,
    required this.patientName,
    required this.documentDate,
    required this.documentId,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      color: const Color.fromARGB(255, 191, 56, 65),
      elevation: 5.0,
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 205, 55, 100),
            foregroundColor: Colors.white,
            radius: 25,
            child: Text(patientName[0], style: const TextStyle(fontSize: 18)),
          ),
          title: Text(
            patientName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color.fromARGB(255, 246, 221, 221)),
          ),
          subtitle: Text(
            documentDate,
            style: const TextStyle(
                fontSize: 16, color: Color.fromARGB(255, 255, 181, 181)),
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
          ),
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
