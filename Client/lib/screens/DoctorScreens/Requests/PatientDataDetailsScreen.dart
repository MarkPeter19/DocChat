import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDataDetailsScreen extends StatefulWidget {
  final String patientId;
  final String documentId;

  PatientDataDetailsScreen({
    required this.patientId,
    required this.documentId,
  });

  @override
  _PatientDataDetailsScreenState createState() =>
      _PatientDataDetailsScreenState();
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
      documentData = await doctorServices.fetchDocumentData(
          widget.patientId, widget.documentId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
              child: Text(value.toString(),
                  textAlign: TextAlign.right, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildAnalysisResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(
            height: 20,
          ),
          Text(value ?? 'N/A', style: TextStyle(fontSize: 16)),
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              Text('Upload Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Expanded(
                child: Text(
                    DateFormat('yyyy-MM-dd – kk:mm').format(
                        (documentData['uploadDate'] as Timestamp).toDate()),
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.right),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Patient Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Gather all data labels and values
    List<Map<String, dynamic>> personalDataLabels = [
      {'label': 'Name:', 'value': patientData['name']},
      {'label': 'Age:', 'value': patientData['age'].toString()},
      {'label': 'Gender:', 'value': patientData['gender']},
      {'label': 'Height:', 'value': patientData['height']},
      {'label': 'Weight:', 'value': patientData['weight']},
      {'label': 'Smoker:', 'value': patientData['smoker']},
      {'label': 'Alcohol consumption:', 'value': patientData['alcohol']},
      {'label': 'Symptoms:', 'value': patientData['symptoms']},
      {'label': 'Medical history:', 'value': patientData['medicalHistory']},
    ];

    return Scaffold(
        appBar: AppBar(title: Text('Patient Details')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Card(
                margin: EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Data',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Divider(),
                      ...personalDataLabels
                          .map((data) =>
                              _buildDataRow(data['label'], data['value']))
                          .toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              //blood analysis
              Card(
                margin: EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blood Analysis Data',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Divider(),
                      _buildAnalysisResultRow(
                          'Analysis Result:', documentData['analysisResult']),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 128,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Csak annyi helyet foglal el, amennyi szükséges
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic to send message
                  },
                  icon: Icon(Icons.comment), // Ikon hozzáadása
                  label: Text(
                    'Message',
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 242, 136, 143),
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 47),
                  ),
                ),
                SizedBox(height: 8), // Térköz hozzáadása a gombok közé
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic to send data to ChatGPT
                  },
                  icon: Icon(Icons.send), // Ikon hozzáadása
                  label:
                      Text('Send To ChatGPT', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 45),
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
