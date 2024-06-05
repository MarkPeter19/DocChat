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
      body: Card(
        elevation: 3,
        color: const Color.fromARGB(255, 230, 94, 98),
        shadowColor: const Color.fromARGB(255, 255, 85, 7),
        child: FutureBuilder<Map<String, dynamic>>(
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                const Color.fromARGB(255, 156, 111, 116),
                            backgroundImage: patientData['profilePictureURL'] !=
                                    null
                                ? NetworkImage(patientData['profilePictureURL'])
                                : null,
                            child: patientData['profilePictureURL'] == ""
                                ? const Icon(Icons.person,
                                    size: 60,
                                    color: Color.fromARGB(255, 216, 209, 209))
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patientData['name'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  patientData['address'],
                                  style: const TextStyle(
                                      fontSize: 17, color: Color.fromARGB(255, 248, 216, 219)),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color.fromARGB(255, 255, 203, 227),),
                      _buildDetailRow(
                        'Gender:',
                        patientData['gender'].toString(),
                      ),
                      _buildDetailRow(
                        'Birth Date:',
                        DateFormat('yyyy-MM-dd').format(
                          (patientData['birthDate'] as Timestamp).toDate(),
                        ),
                      ),
                      _buildDetailRow(
                        'Height (kg):',
                        patientData['height'].toString(),
                      ),
                      _buildDetailRow(
                        'Weight (kg):',
                        patientData['weight'].toString(),
                      ),
                      _buildDetailRow(
                        'Smoker:',
                        patientData['smoker'].toString(),
                      ),
                      _buildDetailRow(
                        'Alcohol:',
                        patientData['alcohol'].toString(),
                      ),
                      _buildDetailRow(
                        'Symptoms:',
                        patientData['symptoms'].toString(),
                      ),
                      _buildDetailRow(
                        'Allergies:',
                        patientData['allergies'].toString(),
                      ),
                      _buildDetailRow(
                        'Current Treatments:',
                        patientData['currentTreatments'].toString(),
                      ),
                      _buildDetailRow(
                        'Medical History:',
                        patientData['medicalHistory'].toString(),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 216, 216)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
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
