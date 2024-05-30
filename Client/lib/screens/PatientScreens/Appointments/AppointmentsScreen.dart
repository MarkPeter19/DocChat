import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/components/appointment_item.dart';
import 'package:doctorgpt/services/appointments_services.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/patient_services.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late String
      _patientId; // Hozzunk létre egy változót a beteg azonosítójának tárolására
  late final AppointmentServices _appointmentServices = AppointmentServices();

  @override
  void initState() {
    super.initState();
    _fetchPatientId(); // Hívjuk meg a beteg azonosítójának lekérdezését
  }

  // Beteg azonosítójának lekérdezése
  Future<void> _fetchPatientId() async {
    try {
      String patientId = await PatientServices().fetchPatientId();
      setState(() {
        _patientId = patientId; // Állítsuk be a beteg azonosítóját a változóba
      });
    } catch (e) {
      print('Error fetching patient id: $e');
      // Kezeljük az esetleges hibákat
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _patientId !=
              null // Ellenőrizzük, hogy a beteg azonosítója készen áll-e
          ? FutureBuilder<List<DocumentSnapshot>>(
              future: AppointmentServices().getAcceptedAppointments(_patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text('No accepted appointments'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return AppointmentItem(
                      doctorId: snapshot.data![index]['doctorId'],
                      date: snapshot.data![index]['date'],
                      hourMinute: snapshot.data![index]['hourMinute'],
                      onTap: () {
                        _showDeclineDialog(snapshot.data![index]
                            .id); // Meghívjuk a dialógust az appointment ID-vel
                      },
                    );
                  },
                );
              },
            )
          : const Center(
              child:
                  CircularProgressIndicator()), // Ha még nincs beteg azonosítója, jelenítsük meg a körbetekerőt
    );
  }

  // decline appointment dialog

  void _showDeclineDialog(String appointmentId) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Color.fromARGB(255, 226, 119, 107),
                    size: 80,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Do you want to decline this appointment?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Type reason for decline',
                    ),
                  ),
                ],
              ),
              actions: [
                // buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Ablak bezárása
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String declineReason = reasonController.text;
                        if (declineReason.isNotEmpty) {
                          _appointmentServices
                              .declineAppointment(appointmentId, declineReason)
                              .then((_) {
                            // AppointmentsScreen újra betöltése
                            Navigator.of(context).pop(); // Ablak bezárása
                            initState();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please provide a reason for declining.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Decline',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
