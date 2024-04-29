import 'package:flutter/material.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/PersonalDataScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import '/components/analysis_item.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class ResponsesScreen extends StatefulWidget {
  @override
  _ResponsesScreenState createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  final PatientServices patientServices = PatientServices();


  @override
  void initState() {
    super.initState();
    //_fetchPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          //doctor's response
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'There are your doctor’s response:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          AnalysisItem(
            doctorName: 'Dr. Doctor message',
            message: 'Short description of the message...',
            date: '2024-04-01',
          ),

          //previous analyses
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Previous analyses:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          AnalysisItem(
            doctorName: 'Dr. Doctor message',
            message: 'Short description of the message...',
            date: '2024-02-13',
          ),
          AnalysisItem(
            doctorName: 'Dr. Doctor message',
            message: 'Short description of the message...',
            date: '2024-01-17',
          ),
          AnalysisItem(
            doctorName: 'Dr. Doctor message',
            message: 'Short description of the message...',
            date: '2024-01-17',
          ),

          // Itt lehet további AnalysisItem-eket hozzáadni...
        ]),
      ),

      //add doc btn
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Add your logic for navigating to Add Doctor screen
      //   },
      //   child: Image.asset('lib/assets/stethoscope.png',
      //       width: 32, height: 32), // Kép méretének beállítása
      //   tooltip: 'Add Doctor',
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PersonalDataScreen()));
          },
          icon: Icon(Icons.assessment),
          label: Text('New Request'),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            minimumSize: Size(double.infinity,
                50),
          ),
        ),
      ),
    );
  }
}
