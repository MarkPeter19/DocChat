import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPatientData(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final patientData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              NetworkImage(patientData['profilePictureURL']),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Name: ${patientData['name']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Address: ${patientData['address']}'),
                      Text('Gender: ${patientData['gender']}'),
                      Text(
                        'Birth Date: ${DateFormat('yyyy-MM-dd').format((patientData['birthDate'] as Timestamp).toDate())}',
                      ),
                      Text('Height: ${patientData['height']}'),
                      Text('Weight: ${patientData['weight']}'),
                      Text('Smoker: ${patientData['smoker']}'),
                      Text('Alcohol: ${patientData['alcohol']}'),
                      Text('Symptoms: ${patientData['symptoms']}'),
                      Text('Allergies: ${patientData['allergies']}'),
                      Text('Medical History: ${patientData['medicalHistory']}'),
                      Text(
                          'Current Treatments: ${patientData['currentTreatments']}'),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchPatientData(String patientId) async {
    try {
      final patientData = await PatientServices().fetchPatientData(patientId);
      return patientData;
    } catch (e) {
      print('Error fetching patient data: $e');
      throw Exception('Error fetching patient data');
    }
  }
}
