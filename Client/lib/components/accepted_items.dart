import 'package:doctorgpt/services/patient_services.dart';
import 'package:flutter/material.dart';

class AcceptedAppointmentItem extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final Map<String, dynamic> date;
  final String hourMinute;
  final VoidCallback onTap;
  final VoidCallback onReschedule; // Reschedule callback

  const AcceptedAppointmentItem({
    Key? key,
    required this.doctorId,
    required this.patientId,
    required this.date,
    required this.hourMinute,
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
          color: const Color.fromARGB(255, 34, 124, 73),
          elevation: 2,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dátum megjelenítése
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDayOfWeek(appointmentDate),
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 255, 255)),
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
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        hourMinute,
                        style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ],
                  ),

                  const SizedBox(width: 15),

                  // paciens neve
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 253, 253, 253),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                patientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                _createDeclineMessageDialog(context);
              }),
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

  void _createDeclineMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 15, 198, 27),
          title: const Text(
            'Reschedule?',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          content: const Text(
            "Do you want to reschedule this appointment?",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 252, 252, 252)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onReschedule();
              },
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.black,
              ),
              label: const Text(
                'Reschedule',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                backgroundColor: const Color.fromARGB(255, 190, 255, 201),
                elevation: 3,
              ),
            ),
          ],
        );
      },
    );
  }
}
