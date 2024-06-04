import 'package:flutter/material.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/ViewAppointmentScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:doctorgpt/services/appointments_services.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/PersonalDataScreen.dart';
import 'package:doctorgpt/components/respond_item.dart';

class ResponsesScreen extends StatefulWidget {
  const ResponsesScreen({Key? key}) : super(key: key);

  @override
  _ResponsesScreenState createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  final AppointmentServices _appointmentServices = AppointmentServices();
  List<Map<String, dynamic>> _appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      String patientId = await PatientServices().fetchPatientId();
      _appointments =
          await _appointmentServices.fetchAppointments(patientId: patientId);
    } catch (e) {
      print('Error fetching patient ID: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                    if (appointment['isAccepted'] ==
                        null) // Csak az elfogadott vagy elutasított időpontokat jelenítjük meg
                      RespondItem(
                        doctorId: appointment['doctorId'],
                        message: appointment['message'],
                        date: appointment['date'],
                        hourMinute: appointment['hourMinute'],
                        sendTime: appointment['sendTime'],
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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PersonalDataScreen()));
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
