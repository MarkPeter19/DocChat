import 'package:flutter/material.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/ViewAppointmentScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:doctorgpt/services/booking_services.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/PersonalDataScreen.dart';
import 'package:doctorgpt/components/appointment_item.dart';

class ResponsesScreen extends StatefulWidget {
  @override
  _ResponsesScreenState createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  final BookingServices _bookingServices = BookingServices();
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      String patientId = await PatientServices().fetchPatientId();
      _appointments = await _bookingServices.fetchAppointments(patientId: patientId);
      setState(() {});
    } catch (e) {
      print('Error fetching patient ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Your doctor’s responses:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            for (var appointment in _appointments)
              AppointmentItem(
                doctorId: appointment['doctorId'],
                message: appointment['message'],
                date: appointment['date'],
                hourMinute: appointment['hourMinute'],
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ViewAppointmentScreen(
                      appointmentId: appointment['id'],
                      doctorId: appointment['doctorId'],
                      date: appointment['date'],
                      hourMinute: appointment['hourMinute'],
                      message: appointment['message'],
                    ),
                  ));
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PersonalDataScreen()));
          },
          icon: const Icon(Icons.assessment),
          label: const Text('New Request'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
