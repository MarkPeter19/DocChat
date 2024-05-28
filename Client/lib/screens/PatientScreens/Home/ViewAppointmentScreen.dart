import 'package:flutter/material.dart';

class ViewAppointmentScreen extends StatelessWidget {
  final String appointmentId;
  final String doctorId;
  final Map<String, dynamic> date;
  final String hourMinute;
  final String message;

  const ViewAppointmentScreen({
    Key? key,
    required this.appointmentId,
    required this.doctorId,
    required this.date,
    required this.hourMinute,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${date['year']}-${date['month']}-${date['day']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Time: $hourMinute',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Message: $message',
              style: const TextStyle(fontSize: 18),
            ),
            // Ide lehet még további adatokat megjeleníteni az appointment objektumból
          ],
        ),
      ),
    );
  }
}
