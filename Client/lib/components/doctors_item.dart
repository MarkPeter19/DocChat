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
    return ListTile(
      title: Text(doctorData['fullName']),
      subtitle: Text(doctorData['specialization']),
      onTap: onTap,
    );
  }
}
