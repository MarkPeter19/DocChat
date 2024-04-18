import 'package:flutter/material.dart';
import 'Requests/RequestsScreen.dart';
import 'Profile/DoctorProfileScreen.dart';
import 'Messages/DoctorMessagesScreen.dart';
import 'Calendar/CalendarScreen.dart';
import 'ChatPDF/ChatPDFScreen.dart';
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
          SizedBox(height: 35,),
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
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $doctorName!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
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
                          minimumSize: Size(double.infinity, 35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Itt jön a TabBar, a profil rész alatt
          PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Requests'),
                Tab(text: 'Messages'),
                Tab(text: 'Calendar'),
                Tab(text: 'ChatPDF'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RequestsScreen(),
                DoctorMessagesScreen(),
                CalendarScreen(),
                ChatPDFScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
