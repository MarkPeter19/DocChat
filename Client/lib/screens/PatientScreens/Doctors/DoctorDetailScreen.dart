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
  bool _isLoading = true;
  Map<String, dynamic>? _doctorData;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _checkIfContactRequestSent();
    _checkIfRequestAccepted();
  }

  Future<void> _loadDoctorData() async {
    try {
      final doctorData =
          await DoctorServices().getAllDoctorDatas(widget.doctorId);
      setState(() {
        _doctorData = doctorData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Card(
              elevation: 3,
              shadowColor: const Color.fromARGB(255, 162, 115, 196),
              color: Color.fromARGB(255, 150, 107, 162),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor:
                                Color.fromARGB(255, 190, 170, 212),
                            backgroundImage:
                                _doctorData!['profilePictureURL'] != null
                                    ? NetworkImage(
                                        _doctorData!['profilePictureURL'])
                                    : null,
                            child: _doctorData!['profilePictureURL'] == ""
                                ? const Icon(Icons.person,
                                    size: 60,
                                    color: Color.fromARGB(255, 144, 102, 163))
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _doctorData!['fullName'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _doctorData!['specialization'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color:
                                          Color.fromARGB(255, 228, 203, 251)),
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        color: Color.fromARGB(255, 203, 159, 244),
                      ),
                      _buildDetailColumn(
                        'Clinic:',
                        _doctorData!['clinic'],
                      ),
                      _buildDetailColumn(
                        'Address:',
                        _doctorData!['address'],
                      ),
                      _buildDetailColumn(
                        'Experience:',
                        _doctorData!['experience'].toString(),
                      ),
                      _buildDetailColumn(
                        'About:',
                        _doctorData!['about'],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      _buildContactButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 220, 173, 248)),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    if (_isContactRequestSent && !_isRequestAccepted) {
      return ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.send, color: Color.fromARGB(255, 186, 186, 186),),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 190, 190, 190),
          minimumSize: const Size(double.infinity, 50),
        ),
        label: const Text('Request Sent', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 179, 179, 179))),
      );
    } else if (_isRequestAccepted) {
      return ElevatedButton.icon(
        onPressed: () {
          // Handle send message action
        },
        icon: const Icon(Icons.message_outlined),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 174, 167, 231),
          minimumSize: const Size(double.infinity, 50),
        ),
        label: const Text(
          'Send Message',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {
          _sendContactRequest(context);
        },
        icon: const Icon(Icons.person),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 87, 188, 148),
          minimumSize: const Size(double.infinity, 50),
        ),
        label: const Text('Get in Contact', style: TextStyle(fontSize: 16)),
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
