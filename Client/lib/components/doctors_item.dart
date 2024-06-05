import 'package:flutter/material.dart';

class DoctorsItem extends StatelessWidget {
  final Map<String, dynamic> doctorData;
  final VoidCallback onTap;

  const DoctorsItem({
    required this.doctorData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30, 
          backgroundColor: const Color.fromARGB(255, 80, 80, 80),
          backgroundImage: doctorData['profilePictureURL'] != null
              ? NetworkImage(doctorData['profilePictureURL'])
              : null,
          child: doctorData['profilePictureURL'] == ""
              ? const Icon(Icons.person, color: Color.fromARGB(255, 216, 209, 209))
              : null,
        ),
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              doctorData['fullName'] ?? 'Unknown Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        subtitle: Wrap(children: [
          Text(
            doctorData['specialization'] ?? 'Unknown Address',
            style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 67, 66, 66)),
          ),
        ]),
        onTap: onTap,
      ),
    );
  }
}
