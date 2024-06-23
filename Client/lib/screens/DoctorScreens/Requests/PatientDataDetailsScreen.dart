import 'package:doctorgpt/screens/DoctorScreens/Requests/ChatScreen.dart';
import 'package:doctorgpt/screens/DoctorScreens/Requests/MakeAppointmentScreen.dart';
import 'package:doctorgpt/services/api_keys.dart';
import 'package:doctorgpt/services/chatPDF_services.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import '../../../services/patient_services.dart';
import 'ViewPDFScreen.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDataDetailsScreen extends StatefulWidget {
  final String patientId;
  final String documentId;

  const PatientDataDetailsScreen({
    super.key,
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
  late String doctorId;
  bool isLoading = true;

  final String apiKey = APIKeys.chatPDFKey;

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
      doctorId = await doctorServices.fetchDoctorId();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
              child: Text(value.toString(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Gather all data labels and values
    List<Map<String, dynamic>> personalDataLabels = [
      {'label': 'Name:', 'value': patientData['name']},
      {
        'label': 'Birth Date:',
        'value': DateFormat('yyyy-MM-dd')
            .format((patientData['birthDate'] as Timestamp).toDate()),
      },
      {'label': 'Gender:', 'value': patientData['gender']},
      {'label': 'Height (cm):', 'value': patientData['height']},
      {'label': 'Weight (kg):', 'value': patientData['weight']},
      {'label': 'Smoker:', 'value': patientData['smoker']},
      {'label': 'Alcohol consumption:', 'value': patientData['alcohol']},
      {'label': 'Allergies:', 'value': patientData['allergies']},
      {'label': 'Symptoms:', 'value': patientData['symptoms']},
      {'label': 'Current treatments:', 'value': patientData['currentTreatments']},
      {'label': 'Medical history:', 'value': patientData['medicalHistory']},
    ];

    return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Patient Data',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const Divider(),
                      ...personalDataLabels
                          .map((data) =>
                              _buildDataRow(data['label'], data['value']))
                          .toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // PDF card
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PDF Document',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            'lib/assets/pdf_logo.png',
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                documentData['PDFName'],
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('yyyy-MM-dd – kk:mm').format(
                                    (documentData['uploadDate'] as Timestamp)
                                        .toDate()),
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to ViewPDFScreen and pass the URL
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewPDFScreen(
                                      pdfUrl: documentData['PDFUrl'],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('View PDF'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 213, 78, 78),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                String? pdfUrl = await PatientServices()
                                    .fetchDocumentPDFUrl(
                                        widget.patientId, widget.documentId);
                                if (pdfUrl != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        pdfUrl: pdfUrl,
                                        doctorId: doctorId,
                                        chatPDFService: ChatPDFService(
                                            apiKey: APIKeys.chatPDFKey),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Kezeljük a null url-t
                                  print(
                                      'Null URL received from fetchDocumentPDFUrl');
                                }
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('Ask ChatPDF'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              //appointement card
              Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Make Appointment',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Divider(),
                          Center(
                            child: Column(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MakeAppointmentScreen(
                                          patientId: widget.patientId,
                                          doctorId: doctorId,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_today),
                                  label: const Text('Make Appointment'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        const Color.fromARGB(255, 78, 182, 116),
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ])),
              ),
            ],
          ),
        ));
  }
}
