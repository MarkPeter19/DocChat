import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import '/components/patient_request_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final DoctorServices doctorServices = DoctorServices();
  List<PatientRequestItem> patientRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPatientRequests();
  }

  // patient requestek betoltese
  Future<void> _fetchPatientRequests() async {
    DoctorServices doctorServices = DoctorServices();
    String doctorId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> requests =
        await doctorServices.fetchPatientRequests(doctorId);

    List<PatientRequestItem> requestItems = requests
        .map((request) => PatientRequestItem(
              patientName: request['patientName'],
              documentDate: request['documentDate'],
              documentId: request['documentId'],
              patientId: request['patientId'],
            ))
        .toList();

    setState(() {
      patientRequests = requestItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //patient requests
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'There are your patient requests:',
              style: TextStyle(fontSize: 18),
            ),
          ),

          // Dinamikus lista megjelenítése a betegkérésekről
          for (var requestItem in patientRequests) requestItem,
          // Itt jeleníti meg a `PatientRequestItem` komponenseket
        ],
      ),
    ));
  }
}
