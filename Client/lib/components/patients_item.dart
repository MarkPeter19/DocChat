import 'package:flutter/material.dart';

class PatientsItem extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final VoidCallback onTap;

  const PatientsItem({
    Key? key,
    required this.patientData,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 249, 40, 78),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30, 
          backgroundColor: const Color.fromARGB(255, 80, 80, 80),
          backgroundImage: patientData['profilePictureURL'] != null
              ? NetworkImage(patientData['profilePictureURL'])
              : null,
          child: patientData['profilePictureURL'] == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              patientData['name'] ?? 'Unknown Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        subtitle: Wrap(children: [
          Text(
            patientData['address'] ?? 'Unknown Address',
            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 255, 209, 209)),
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}
