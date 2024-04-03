import 'package:flutter/material.dart';
import '/screens/DoctorScreens/DoctorProfileScreen.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import '/components/patient_request_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  String doctorName = "Loading...";
  final DoctorServices doctorServices = DoctorServices();
  List<PatientRequestItem> patientRequests = [];

  

  @override
  void initState() {
    super.initState();
    _fetchDoctorData();
    _fetchPatientRequests();
  }

  // Fetch doctor name
  Future<void> _fetchDoctorData() async {
    String fetchedDoctorName = await doctorServices.fetchDoctorName();
    // Add code to fetch patient requests as well
    setState(() {
      doctorName = fetchedDoctorName;
    });
  }

  // patient requestek betoltese
  Future<void> _fetchPatientRequests() async {
    DoctorServices doctorServices = DoctorServices();
    String doctorId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> requests = await doctorServices.fetchPatientRequests(doctorId);

    List<PatientRequestItem> requestItems = requests
      .map((request) => PatientRequestItem(
          patientName: request['patientName'],
          documentDate: request['documentDate'],
          // További adatok, ha szükséges
        ))
      .toList();

    setState(() {
      patientRequests = requestItems;
    });
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
                      radius: 50, // Profilkép mérete
                      backgroundColor: Colors.grey, // Profilkép háttérszíne
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
                            'Hi, $doctorName!',
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
                                  builder: (context) => DoctorProfileScreen()),
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
