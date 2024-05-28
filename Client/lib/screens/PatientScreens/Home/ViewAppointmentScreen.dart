import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 69, 167, 83)
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Hi, you have got an appointment, is it suitable for you?',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<String>(
                    future: DoctorServices().getDoctorName(doctorId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 123, 203, 247), // Változtatható szín
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        title: Text(snapshot.data ?? "Unknown", style: const TextStyle(fontSize: 18),),
                      );
                    },
                  ),
                  FutureBuilder<String>(
                    future: DoctorServices().getDoctorAddress(doctorId),
                    builder: (context, addressSnapshot) {
                      if (addressSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (addressSnapshot.hasError) {
                        return Text('Error: ${addressSnapshot.error}');
                      }
                      return ListTile(
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 235, 164, 58), 
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.location_on, color: Colors.white),
                          ),
                        ),
                        title: Text(addressSnapshot.data ?? "Unknown Address", style: const TextStyle(fontSize: 18)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 125, 211, 75), // Változtatható szín
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.calendar_today, color: Colors.white),
                      ),
                    ),
                    title: Text('Date: ${date['year']}-${date['month']}-${date['day']}', style: const TextStyle(fontSize: 18)),
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 209, 103, 128),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.access_time, color: Colors.white),
                      ),
                    ),
                    title: Text('Time: $hourMinute', style: const TextStyle(fontSize: 18)),
                  ),
                  ListTile(
                    leading: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 184, 78, 203), // Változtatható szín
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.message, color: Colors.white),
                      ),
                    ),
                    title: Text(message, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add logic for accept button
                        },
                        child: const Text('Accept'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add logic for decline button
                        },
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Text input for decline reason
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Reason for Decline',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add logic for send respond button
                    },
                    child: const Text('Send Respond'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
