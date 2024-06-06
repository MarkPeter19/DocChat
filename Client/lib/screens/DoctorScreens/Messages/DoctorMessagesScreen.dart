import 'package:doctorgpt/components/patients_item.dart';
import 'package:doctorgpt/screens/doctorScreens/Messages/DoctorChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class DoctorMessagesScreen extends StatelessWidget {
  const DoctorMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<String>(
        future: DoctorServices().fetchDoctorId(),
        builder: (context, doctorIdSnapshot) {
          if (doctorIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (doctorIdSnapshot.hasError) {
            return Center(child: Text('Error: ${doctorIdSnapshot.error}'));
          } else if (doctorIdSnapshot.hasData) {
            final doctorId = doctorIdSnapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: DoctorServices().fetchMyPatients(doctorId),
              builder: (context, doctorsSnapshot) {
                if (doctorsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (doctorsSnapshot.hasError) {
                  return Center(child: Text('Error: ${doctorsSnapshot.error}'));
                } else if (doctorsSnapshot.hasData) {
                  final patients = doctorsSnapshot.data!;
                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return PatientsItem(
                        patientData: patient,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorChatScreen(
                                  patientId: patient['id'], doctorId: doctorId),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No patients found'));
                }
              },
            );
          } else {
            return const Center(child: Text('No patient ID found'));
          }
        },
      ),
    );
  }
}
