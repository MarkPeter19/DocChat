import 'package:flutter/material.dart';

class PatientsItem extends StatelessWidget {
  final Map<String, dynamic> patientData;
  final VoidCallback onTap;

  const PatientsItem({super.key, 
    required this.patientData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: patientData['profilePictureURL'] != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(patientData['profilePictureURL']),
            )
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(patientData['name'] ?? 'Unknown Name'),
      subtitle: Text(patientData['address'] ?? 'Unknown Address'),
      onTap: onTap,
    );
  }
}
