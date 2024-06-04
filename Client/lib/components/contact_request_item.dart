import 'package:flutter/material.dart';
import 'package:doctorgpt/services/patient_services.dart';

class ContactRequestItem extends StatelessWidget {
  final String patientId;
  //final DateTime time;
  final Function() onAccept;
  final Function() onDecline;

  const ContactRequestItem({
    Key? key,
    required this.patientId,
    //required this.time,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PatientServices().getPatientName(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
            //subtitle: Text(time.toString()),
          );
        } else if (snapshot.hasError) {
          return const ListTile(
            title: Text('Error'),
            //subtitle: Text(time.toString()),
          );
        } else {
          final patientName = snapshot.data ?? 'Unknown';
          return ListTile(
            title: Text(patientName),
            //subtitle: Text(time.toString()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onAccept, 
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDecline, 
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
