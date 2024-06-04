import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/components/contact_request_item.dart';
import 'package:doctorgpt/components/patients_item.dart';
import 'package:doctorgpt/screens/DoctorScreens/Patients/PatientDetailScreen.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class PatientsScreen extends StatefulWidget {
  @override
  _PatientsScreenState createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<DocumentSnapshot>> _contactRequests;
  late Future<List<Map<String, dynamic>>> _myPatients;
  late TabController _tabController;
  late String _doctorId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _doctorId = await DoctorServices().fetchDoctorId();

      await _loadData();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData() async {
    _contactRequests = DoctorServices().fetchContactRequests(_doctorId);
    _myPatients = DoctorServices().fetchMyPatients(_doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Contact Requests'),
              Tab(text: 'My Patients'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContactRequestsList(),
                _buildMyPatientsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRequestsList() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _contactRequests,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final request = snapshot.data![index];
              return ContactRequestItem(
                patientId: request['patientId'],
                //timestamp: request['timestamp'],
                onAccept: () async {
                  try {
                    await DoctorServices()
                        .updateContactRequestStatus(request.id, true);
                    print('Accepted ${request['patientId']}');
                  } catch (e) {
                    print('Error accepting request: $e');
                  }
                },
                onDecline: () async {
                  try {
                    await DoctorServices()
                        .updateContactRequestStatus(request.id, false);
                    print('Declined ${request['patientId']}');
                  } catch (e) {
                    print('Error declining request: $e');
                  }
                },
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildMyPatientsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _myPatients,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return PatientsItem(
                patientData: snapshot.data![index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailScreen(
                        patientId: snapshot.data![index]['id'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
