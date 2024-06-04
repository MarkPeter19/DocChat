import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:doctorgpt/services/patient_services.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;

  const DoctorDetailsScreen({Key? key, required this.doctorId, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DoctorServices().getAllDoctorDatas(doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildDoctorDetails(context, snapshot.data!);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildDoctorDetails(BuildContext context, Map<String, dynamic> doctorData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(doctorData['profilePictureURL']),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Name'),
            subtitle: Text(doctorData['fullName']),
          ),
          ListTile(
            title: Text('Specialization'),
            subtitle: Text(doctorData['specialization']),
          ),
          ListTile(
            title: Text('Clinic'),
            subtitle: Text(doctorData['clinic']),
          ),
          ListTile(
            title: Text('Address'),
            subtitle: Text(doctorData['address']),
          ),
          ListTile(
            title: Text('Experience'),
            subtitle: Text(doctorData['experience']),
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text(doctorData['about']),
          ),
          ElevatedButton(
            onPressed: () {
              _sendContactRequest(context);
            },
            child: Text('Get in Contact'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendContactRequest(BuildContext context) async {
    try {
      await PatientServices().sendContactRequest(doctorId, patientId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Contact request sent successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error sending contact request: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
