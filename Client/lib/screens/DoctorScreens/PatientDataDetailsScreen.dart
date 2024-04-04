import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class PatientDataDetailsScreen extends StatefulWidget {
  final String patientId;
  final String documentId;

  PatientDataDetailsScreen({
    required this.patientId,
    required this.documentId,
  });

  @override
  _PatientDataDetailsScreenState createState() => _PatientDataDetailsScreenState();
}

class _PatientDataDetailsScreenState extends State<PatientDataDetailsScreen> {
  late Map<String, dynamic> patientData;
  late Map<String, dynamic> documentData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  
  Future<void> _fetchData() async {
  DoctorServices doctorServices = DoctorServices();
  try {
    patientData = await doctorServices.fetchPatientData(widget.patientId);
    documentData = await doctorServices.fetchDocumentData(widget.patientId, widget.documentId);
    setState(() {
      isLoading = false;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching data: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(patientData['name']),
                  SizedBox(height: 20,),
                  Text(documentData['analysisResult'])
                  // Itt jelenítheti meg a páciens adatokat
                  // Például Text(patientData['name']) stb.

                  // Itt jelenítheti meg a dokumentum adatokat
                  // Például Text(documentData['analysisResult']) stb.
                ],
              ),
            ),
    );
  }
}
