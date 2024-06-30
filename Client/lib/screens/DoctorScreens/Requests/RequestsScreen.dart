import 'package:flutter/material.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import '/components/patient_request_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final DoctorServices doctorServices = DoctorServices();
  List<PatientRequestItem> patientRequests = [];
  bool isLoading = true;
  String _sortOption = 'Date'; // Default sort option

  @override
  void initState() {
    super.initState();
    _fetchPatientRequests();
  }

  // Fetch patient requests
  Future<void> _fetchPatientRequests() async {
    try {
      DoctorServices doctorServices = DoctorServices();
      String doctorId = FirebaseAuth.instance.currentUser!.uid;
      List<Map<String, dynamic>> requests =
          await doctorServices.fetchPatientRequests(doctorId);

      List<PatientRequestItem> requestItems = requests
          .map((request) => PatientRequestItem(
                patientName: request['patientName'],
                documentDate: request['documentDate'],
                documentId: request['documentId'],
                patientId: request['patientId'],
                tag: request['tag'],
              ))
          .toList();

      setState(() {
        patientRequests = requestItems;
        _sortRequests(); // Sort requests after fetching
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching patient requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sort requests based on the selected option
  void _sortRequests() {
    switch (_sortOption) {
      case 'Name':
        patientRequests.sort((a, b) => a.patientName.compareTo(b.patientName));
        break;
      case 'Date':
        patientRequests.sort((a, b) => DateFormat('yyyy-MM-dd – kk:mm')
            .parse(b.documentDate)
            .compareTo(DateFormat('yyyy-MM-dd – kk:mm').parse(a.documentDate)));
        break;
      case 'Tag':
        patientRequests.sort((a, b) {
          // Define the order of tags
          Map<String, int> tagOrder = {
            'urgent': 0,
            'not urgent': 1,
            'none': 2,
            'done': 3,
          };

          // Get the order index for each tag or set it to a high number if tag is not in the map
          int aOrder = tagOrder[a.tag] ?? 999;
          int bOrder = tagOrder[b.tag] ?? 999;

          return aOrder.compareTo(bOrder);
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'These are your patient requests:',
          style: TextStyle(fontSize: 18),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Sort options
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
                _sortRequests();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem(
                value: 'Name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'Tag',
                child: Text('Sort by Tag'),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient requests
                  for (var requestItem in patientRequests) requestItem,
                ],
              ),
            ),
    );
  }
}
