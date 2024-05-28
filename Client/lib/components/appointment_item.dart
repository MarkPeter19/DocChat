import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class AppointmentItem extends StatelessWidget {
  final String doctorId;
  final String message;
  final Map<String, dynamic> date;
  final String hourMinute;
  final VoidCallback onTap;

  const AppointmentItem({
    required this.doctorId,
    required this.message,
    required this.date,
    required this.hourMinute, // Új paraméter hozzáadása
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        '${date['year']}-${date['month']}-${date['day']} ${hourMinute ?? ''}';

    return FutureBuilder(
      future: DoctorServices().getDoctorName(doctorId),
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Várakozás jelző megjelenítése
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Hiba esetén hibaüzenet megjelenítése
        }
        // Sikeres lekérdezés esetén az orvos nevének megjelenítése
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green, // Zöld kör háttérszín
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.calendar_today, color: Colors.white), // Naptár ikon
              ),
            ),
            title: Text(
              snapshot.data ?? 'Unknown', // Orvos neve
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(formattedDate),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: onTap,
          ),
        );
      },
    );
  }
}
