import 'package:flutter/material.dart';
import 'Requests/RequestsScreen.dart';
import 'Profile/DoctorProfileScreen.dart';
import 'Messages/DoctorMessagesScreen.dart';
import 'Appointments/DoctorAppointmentsScreen.dart';
import 'Patients/PatientsScreen.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String doctorName = "Loading...";
  String profileImageUrl = "";
  final DoctorServices doctorServices = DoctorServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _fetchDoctorData();
  }

  // Fetch doctor data
  Future<void> _fetchDoctorData() async {
    String fetchedDoctorName = await doctorServices.fetchDoctorUserName();
    Map<String, String> doctorDetails = await doctorServices
        .fetchDoctorDetails(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      doctorName = fetchedDoctorName;
      profileImageUrl = doctorDetails['profilePictureURL'] ?? "";
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
                        'Hi, $doctorName!',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen()),
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
                  fontSize: 15,
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
                RequestsScreen(),
                const DoctorAppointmentsScreen(),
                DoctorMessagesScreen(),
                PatientsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
