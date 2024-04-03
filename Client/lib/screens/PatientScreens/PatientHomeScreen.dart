import 'package:flutter/material.dart';
import '/screens/PatientScreens/PersonalDataScreen.dart';
import '/screens/PatientScreens/PatientProfileScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import '/components/analysis_item.dart';


class PatientHomeScreen extends StatefulWidget {
   @override
  _PatientHomeScreenState createState() =>
      _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  String username = "Loading...";
  final PatientServices userServices = PatientServices();

  //fetch username
  Future<void> _fetchUsername() async {
    String fetchedUsername = await userServices.fetchUsername();
    setState(() {
      username = fetchedUsername;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUsername();
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
