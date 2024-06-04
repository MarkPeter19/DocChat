import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'package:doctorgpt/services/patient_services.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;

  const DoctorDetailsScreen(
      {Key? key, required this.doctorId, required this.patientId})
      : super(key: key);

  @override
  _DoctorDetailsScreenState createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isContactRequestSent = false;
  bool _isRequestAccepted = false;

  @override
  void initState() {
    super.initState();
    _checkIfContactRequestSent();
    _checkIfRequestAccepted();
  }

  void _checkIfContactRequestSent() async {
    bool isSent = await PatientServices()
        .isContactRequestSent(widget.doctorId, widget.patientId);
    setState(() {
      _isContactRequestSent = isSent;
    });
  }

  void _checkIfRequestAccepted() async {
    bool isAccepted = await PatientServices()
        .isContactRequestAccepted(widget.doctorId, widget.patientId);
    setState(() {
      _isRequestAccepted = isAccepted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: DoctorServices().getAllDoctorDatas(widget.doctorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildDoctorDetails(context, snapshot.data!);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildDoctorDetails(
      BuildContext context, Map<String, dynamic> doctorData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(doctorData['profilePictureURL']),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Name'),
              subtitle: Text(doctorData['fullName']),
            ),
            ListTile(
              title: Text('Specialization'),
              subtitle: Text(doctorData['specialization']),
            ),
            ListTile(
              title: Text('Clinic'),
              subtitle: Text(doctorData['clinic']),
            ),
            ListTile(
              title: Text('Address'),
              subtitle: Text(doctorData['address']),
            ),
            ListTile(
              title: Text('Experience'),
              subtitle: Text(doctorData['experience']),
            ),
            ListTile(
              title: Text('About'),
              subtitle: Text(doctorData['about']),
            ),
            _buildContactButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    if (_isContactRequestSent && !_isRequestAccepted) {
      return ElevatedButton(
        onPressed: null,
        child: Text('Request Sent'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey,
        ),
      );
    } else if (_isRequestAccepted) {
      return ElevatedButton(
        onPressed: () {
          // Handle send message action
        },
        child: Text('Send Message'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          _sendContactRequest(context);
        },
        child: Text('Get in Contact'),
      );
    }
  }

  Future<void> _sendContactRequest(BuildContext context) async {
    try {
      await PatientServices()
          .sendContactRequest(widget.doctorId, widget.patientId);
      setState(() {
        _isContactRequestSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Contact request sent successfully'),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error sending contact request: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
