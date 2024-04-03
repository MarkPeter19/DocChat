import 'package:flutter/material.dart';


class PatientRequestItem extends StatelessWidget {
  final String patientName;
  final String documentDate;

  PatientRequestItem({
    required this.patientName,
    required this.documentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple,
          child: Text(patientName[0]), // A páciens nevének első betűje
        ),
        title: Text(
          patientName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(documentDate), // A dokumentum feltöltési idejének megjelenítése
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          // Navigáció a részletek képernyőre
        },
      ),
    );
  }
}
