import 'package:flutter/material.dart';
import '/screens/PatientScreens/PersonalDataScreen.dart';
import '/screens/PatientScreens/PatientProfileScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import '/components/analysis_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHomeScreen extends StatefulWidget {
  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String username = "Loading...";
  String profileImageUrl = "";
  final PatientServices patientServices = PatientServices();

  // Fetch patient data
  Future<void> _fetchPatientData() async {
    String fetchedPatientUserName =
        await patientServices.fetchPatientUserName();
    Map<String, String> patientDetails = await patientServices
        .fetchPatientDetails(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      username = fetchedPatientUserName;
      profileImageUrl = patientDetails['profilePictureURL'] ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontSize: 26)),
        elevation: 20, // AppBar árnyékának eltávolítása
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey.shade800,
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Hi, $username!',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        //edit profile
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PatientProfileScreen()),
                          ),
                          icon: Icon(Icons.person_outline),
                          label: Text('View Profile'),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            onPrimary: Colors.white,
                            minimumSize: Size(double.infinity,
                                35), //  Gomb szélességének és magasságának beállítása
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
          ],
        ),
      ),

      //add doc btn
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic for navigating to Add Doctor screen
        },
        child: Image.asset('lib/assets/stethoscope.png',
            width: 32, height: 32), // Kép méretének beállítása
        tooltip: 'Add Doctor',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PersonalDataScreen()));
          },
          icon: Icon(Icons.assessment),
          label: Text('New Analysis'),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Colors.white,
            minimumSize: Size(double.infinity,
                50), //  Gomb szélességének és magasságának beállítása
          ),
        ),
      ),
    );
  }
}
