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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientRequests();
  }

  // patient requestek betoltese
  Future<void> _fetchPatientRequests() async {
    try {
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
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching patient requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //patient requests
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'There are your patient requests:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    for (var requestItem in patientRequests) requestItem,
                  ],
                ),
              ));
  }
}
