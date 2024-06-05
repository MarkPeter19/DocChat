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
  Future<List<DocumentSnapshot>>? _contactRequests;
  Future<List<Map<String, dynamic>>>? _myPatients;
  late TabController _tabController;
  late String _doctorId;
  bool isLoading = true;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _doctorId = await DoctorServices().fetchDoctorId();
      _contactRequests = DoctorServices().fetchContactRequests(_doctorId);
      _myPatients = DoctorServices().fetchMyPatients(_doctorId);
      await Future.wait([_contactRequests!, _myPatients!]);
      setState(() {
        _dataLoaded = true;
      });
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
    if (_contactRequests == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return FutureBuilder<List<DocumentSnapshot>>(
        future: _contactRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("There aren't any new requests"));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final request = snapshot.data![index];
                return ContactRequestItem(
                  patientId: request['patientId'],
                  onAccept: () async {
                    try {
                      await DoctorServices()
                          .updateContactRequestStatus(request.id, true);
                      print('Accepted ${request['patientId']}');
                      _refreshContactRequestsList();
                    } catch (e) {
                      print('Error accepting request: $e');
                    }
                  },
                  onDecline: () async {
                    try {
                      await DoctorServices()
                          .updateContactRequestStatus(request.id, false);
                      print('Declined ${request['patientId']}');
                      _refreshContactRequestsList();
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
  }

  void _refreshContactRequestsList() {
    setState(() {
      _contactRequests = DoctorServices().fetchContactRequests(_doctorId);
      _myPatients = DoctorServices().fetchMyPatients(_doctorId);
    });
  }

  Widget _buildMyPatientsList() {
    if (_myPatients == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: _myPatients,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("You don't have any patients yet"));
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
}
