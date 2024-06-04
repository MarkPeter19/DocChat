import 'package:doctorgpt/screens/PatientScreens/Appointments/AppointmentsScreen.dart';
import 'package:flutter/material.dart';
import 'package:doctorgpt/screens/PatientScreens/Home/ResponsesScreen.dart';
import 'Profile/PatientProfileScreen.dart';
import 'Messages/PatientMessagesScreen.dart';
import 'Doctors/DoctorsScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String username = "Loading...";
  String profileImageUrl = "";
  final PatientServices patientServices = PatientServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _fetchPatientData();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 45,
          ),
          //profile resz
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $username!',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PatientProfileScreen()),
                        ),
                        icon: const Icon(Icons.person_outline),
                        label: const Text('View Profile'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Theme.of(context).colorScheme.secondary,
                          minimumSize: const Size(double.infinity, 35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TabBar
          PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Material(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                tabs: const [
                  Tab(icon: Icon(Icons.home)),
                  Tab(icon: Icon(Icons.calendar_today)),
                  Tab(icon: Icon(Icons.message)),
                  Tab(icon: Icon(Icons.people)),
                ],
                labelStyle: const TextStyle(
                  fontSize: 1,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: const EdgeInsets.only(bottom: 5.0),
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const ResponsesScreen(),
                const AppointmentsScreen(),
                PatientMessagesScreen(),
                DoctorsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
