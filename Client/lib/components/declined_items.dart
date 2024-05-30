import 'package:doctorgpt/services/patient_services.dart';
import 'package:flutter/material.dart';

class DeclinedAppointmentItem extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final Map<String, dynamic> date;
  final String hourMinute;
  final String declineMessage;
  final VoidCallback onTap;
  final VoidCallback onReschedule; // Reschedule callback

  const DeclinedAppointmentItem({
    Key? key,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.hourMinute,
    required this.declineMessage,
    required this.onTap,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime appointmentDate = DateTime(
      date['year'],
      date['month'],
      date['day'],
    );

    return FutureBuilder<Map<String, String>>(
      future: _fetchPatientData(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final patientName = snapshot.data?['name'] ?? 'Unknown';

        return Card(
          color: Color.fromARGB(255, 157, 106, 10),
          elevation: 2,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Row(
              children: [
                // Dátum megjelenítése
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayOfWeek(appointmentDate),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 234, 234, 234)),
                    ),
                    Text(
                      appointmentDate.day.toString(),
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    Text(
                      _getMonth(appointmentDate),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 254, 254, 254)),
                    ),
                  ],
                ),
                const SizedBox(width: 15),

                // Idő megjelenítése
                Text(
                  hourMinute,
                  style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255)),
                ),

                const SizedBox(width: 35),
                // paciens neve
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 253, 253, 253),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        patientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              _showDeclineMessageDialog(context, declineMessage);
            },
          ),
        );
      },
    );
  }

  String _getDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonth(DateTime date) {
    switch (date.month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'December';
      default:
        return '';
    }
  }

  Future<Map<String, String>> _fetchPatientData(String patientId) async {
    final patientServices = PatientServices();
    final patientName = await patientServices.getPatientName(patientId);
    return {'name': patientName};
  }

  void _showDeclineMessageDialog(BuildContext context, String declineMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.amber,
          title: const Text(
            'Decline Message',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          content: Text(
            declineMessage,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onReschedule();
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text(
                    'Reschedule',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 255, 227, 190),
                    elevation: 3,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
