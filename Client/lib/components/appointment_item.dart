import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class AppointmentItem extends StatelessWidget {
  final String doctorId;
  final Map<String, dynamic> date;
  final String hourMinute;
  final VoidCallback onTap;

  const AppointmentItem({
    Key? key,
    required this.doctorId,
    required this.date,
    required this.hourMinute,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime appointmentDate = DateTime(
      date['year'],
      date['month'],
      date['day'],
    );

    return FutureBuilder<Map<String, String>>(
      future: _fetchDoctorData(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final doctorName = snapshot.data?['name'] ?? 'Unknown';
        final doctorAddress = snapshot.data?['address'] ?? 'Unknown';

        return Card(
          color: const Color.fromARGB(255, 64, 44, 86),
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
                      _getDayOfWeek(appointmentDate), // nap
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 211, 100, 236)),
                    ),
                    Text(
                      appointmentDate.day.toString(), // Nap
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 211, 100, 236),
                      ),
                    ),
                    Text(
                      _getMonth(appointmentDate), // Hónap
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 211, 100, 236)),
                    ),
                  ],
                ),
                const SizedBox(width: 15),

                // Time megjelenítése
                Column(
                  children: [
                    const SizedBox(height: 20,),
                    Text(
                      hourMinute,
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 6, 126),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 15),

                // Orvos neve és címe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Icon(Icons.person,
                              color: Color.fromARGB(255, 211, 100, 236)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Color.fromARGB(255, 211, 100, 236)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doctorAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
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
            onTap: onTap,
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

  Future<Map<String, String>> _fetchDoctorData(String doctorId) async {
    final doctorServices = DoctorServices();
    final doctorName = await doctorServices.getDoctorName(doctorId);
    final doctorAddress = await doctorServices.getDoctorAddress(doctorId);
    return {'name': doctorName, 'address': doctorAddress};
  }
}
