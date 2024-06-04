import 'package:flutter/material.dart';
import 'package:doctorgpt/components/doctors_item.dart';
import 'package:doctorgpt/screens/PatientScreens/Doctors/DoctorDetailScreen.dart';
import 'package:doctorgpt/services/patient_services.dart';

class DoctorsScreen extends StatefulWidget {
  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _allDoctors;
  late Future<List<Map<String, dynamic>>> _myDoctors;
  late TabController _tabController;
  late String _patientId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Először lekérjük a beteg azonosítóját
      _patientId = await PatientServices().fetchPatientId();
      // Miután megkaptuk az azonosítót, betöltjük az adatokat
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
    _allDoctors = PatientServices().fetchAllDoctors();
    _myDoctors = PatientServices().fetchMyDoctors(_patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'My Doctors'),
                      Tab(text: 'All Doctors'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMyDoctorsList(),
                        _buildAllDoctorsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAllDoctorsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _allDoctors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return DoctorsItem(
                doctorData: snapshot.data![index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailsScreen(
                        doctorId: snapshot.data![index]['id'],
                        patientId: _patientId,
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

  Widget _buildMyDoctorsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _myDoctors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return DoctorsItem(
                doctorData: snapshot.data![index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailsScreen(
                        doctorId: snapshot.data![index]['id'],
                        patientId: _patientId,
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
