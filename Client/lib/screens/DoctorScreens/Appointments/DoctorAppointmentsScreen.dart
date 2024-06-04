import 'package:doctorgpt/components/accepted_items.dart';
import 'package:doctorgpt/components/declined_items.dart';
import 'package:doctorgpt/screens/DoctorScreens/Appointments/RescheduleAppointmentScreen.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/services/appointments_services.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  _DoctorAppointmentsScreenState createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentServices _appointmentServices = AppointmentServices();
  late String _doctorId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorId();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Az orvos azonosítójának lekérdezése
  Future<void> _fetchDoctorId() async {
    try {
      String doctorId = await DoctorServices().fetchDoctorId();
      setState(() {
        _doctorId = doctorId;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching doctor id: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Accepted'),
                Tab(text: 'Declined'),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentsList(
                            true), // Elfogadott időpontok listája
                        _buildAppointmentsList(
                            false), // Visszamondott időpontok listája
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(bool isAccepted) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: isAccepted
          ? _appointmentServices.getAcceptedAppointmentsForDoctor(_doctorId)
          : _appointmentServices.getDeclinedAppointmentsforDoctor(_doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            DocumentSnapshot appointment = snapshot.data![index];
            return isAccepted
                ? AcceptedAppointmentItem(
                    doctorId: _doctorId,
                    patientId: appointment['patientId'],
                    date: appointment['date'],
                    hourMinute: appointment['hourMinute'],
                    onTap: () {},
                    // Reschedule callback hozzáadása
                    onReschedule: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RescheduleAppointmentScreen(
                            oldAppointmentId: appointment
                                .id, // A visszamondott időpont azonosítója,
                            patientId: appointment['patientId'],
                            doctorId: _doctorId,
                          ),
                        ),
                      );
                    })
                : DeclinedAppointmentItem(
                    doctorId: _doctorId,
                    patientId: appointment['patientId'],
                    date: appointment['date'],
                    hourMinute: appointment['hourMinute'],
                    declineMessage: appointment['declineMessage'],
                    onTap: () {},
                    // Reschedule callback hozzáadása
                    onReschedule: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RescheduleAppointmentScreen(
                            oldAppointmentId: appointment
                                .id, // A visszamondott időpont azonosítója,
                            patientId: appointment['patientId'],
                            doctorId: _doctorId,
                          ),
                        ),
                      );
                    });
          },
        );
      },
    );
  }
}
