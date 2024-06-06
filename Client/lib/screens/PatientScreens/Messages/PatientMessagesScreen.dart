import 'package:doctorgpt/screens/PatientScreens/Messages/PatientChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:doctorgpt/components/doctors_item.dart';

class PatientMessagesScreen extends StatelessWidget {
  const PatientMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<String>(
        future: PatientServices().fetchPatientId(),
        builder: (context, patientIdSnapshot) {
          if (patientIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (patientIdSnapshot.hasError) {
            return Center(child: Text('Error: ${patientIdSnapshot.error}'));
          } else if (patientIdSnapshot.hasData) {
            final patientId = patientIdSnapshot.data!;
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: PatientServices().fetchMyDoctors(patientId),
              builder: (context, doctorsSnapshot) {
                if (doctorsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (doctorsSnapshot.hasError) {
                  return Center(child: Text('Error: ${doctorsSnapshot.error}'));
                } else if (doctorsSnapshot.hasData) {
                  final doctors = doctorsSnapshot.data!;
                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return DoctorsItem(
                        doctorData: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientChatScreen(
                                  patientId: patientId, doctorId: doctor['id']),
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No doctors found'));
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
