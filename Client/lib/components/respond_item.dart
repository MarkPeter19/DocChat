import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class RespondItem extends StatelessWidget {
  final String doctorId;
  final String message;
  final Map<String, dynamic> date;
  final String hourMinute;
  final Timestamp? sendTime;
  final VoidCallback onTap;

  const RespondItem({
    Key? key,
    required this.doctorId,
    required this.message,
    required this.date,
    required this.hourMinute,
    required this.sendTime,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        '${date['year']}-${date['month']}-${date['day']} $hourMinute';

    String? sentAt = sendTime != null
        ? '${sendTime!.toDate().year}-${sendTime!.toDate().month}-${sendTime!.toDate().day} ${sendTime!.toDate().hour}:${sendTime!.toDate().minute}'
        : null;

    return FutureBuilder(
      future: DoctorServices().getDoctorName(doctorId),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Card(
          elevation: 2,
          color: Color.fromRGBO(212, 255, 219, 1),
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.calendar_today, color: Colors.white),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data ?? 'Unknown',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (sendTime != null) // Csak akkor jelenítsd meg, ha nem null
                  Text(
                    'Sent at: $sentAt',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 103, 101, 101)),
                  ),
              ],
            ),
            subtitle: Text(
              'Appointment: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
