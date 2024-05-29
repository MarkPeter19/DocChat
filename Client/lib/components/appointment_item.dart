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
    // Az időpont megjelenítése formázva
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
                      _getDayOfWeek(appointmentDate), // nap
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      appointmentDate.day.toString(), // Nap
                      style: const TextStyle(
                          fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getMonth(appointmentDate), // Hónap
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(
                    width: 15), // Szünet a dátum és az orvos neve között

                // time
                Text(
                  hourMinute,
                  style: const TextStyle(
                      fontSize: 35, fontWeight: FontWeight.bold),
                ),

                const SizedBox(width: 15),
                // Orvos neve és címe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            doctorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      // Address megjelenítése két sorban, ha hosszabb, mint a megadott maximális hossz
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 40, // Két sor maximális magassága
                              child: Text(
                                doctorAddress,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2, // Maximum két sor
                                overflow: TextOverflow
                                    .ellipsis, // Több sor esetén ellipszist jelenít meg
                              ),
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

  // Hét napjának lekérése
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

  // Hónap lekérése
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

  // Orvos adatok lekérése
  Future<Map<String, String>> _fetchDoctorData(String doctorId) async {
    final doctorServices = DoctorServices();
    final doctorName = await doctorServices.getDoctorName(doctorId);
    final doctorAddress = await doctorServices.getDoctorAddress(doctorId);
    return {'name': doctorName, 'address': doctorAddress};
  }
}
