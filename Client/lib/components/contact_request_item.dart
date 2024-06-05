import 'package:flutter/material.dart';
import 'package:doctorgpt/services/patient_services.dart';

class ContactRequestItem extends StatelessWidget {
  final String patientId;
  final Function() onAccept;
  final Function() onDecline;

  const ContactRequestItem({
    Key? key,
    required this.patientId,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PatientServices().getPatientName(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingTile();
        } else if (snapshot.hasError) {
          return _buildErrorTile();
        } else {
          final patientName = snapshot.data ?? 'Unknown';
          return _buildContactRequestCard(patientName, context);
        }
      },
    );
  }

  Widget _buildLoadingTile() {
    return const ListTile(
      title: Text('Loading...'),
    );
  }

  Widget _buildErrorTile() {
    return const ListTile(
      title: Text('Error'),
    );
  }

  Widget _buildContactRequestCard(String patientName, BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                patientName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onAccept,
                  color: Colors.green,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onDecline,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
