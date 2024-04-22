import 'package:doctorgpt/screens/PatientScreens/PatientHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorgpt/services/patient_services.dart';

class ViewAnalysisResultScreen extends StatefulWidget {
  final String result;

  ViewAnalysisResultScreen({required this.result});

  @override
  _ViewAnalysisResultScreenState createState() =>
      _ViewAnalysisResultScreenState();
}

class _ViewAnalysisResultScreenState extends State<ViewAnalysisResultScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final PatientServices patientServices = PatientServices();
  bool _isSaved = false;
  String? _savedDocumentId;
  List<Map<String, dynamic>> doctorsList = [];
  String? selectedDoctorId;

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.result;
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      var fetchedDoctors = await patientServices.fetchDoctors();
      if (fetchedDoctors.isNotEmpty) {
        setState(() {
          doctorsList = fetchedDoctors;
          selectedDoctorId = doctorsList.first['id'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load doctors: $e')),
      );
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a doctor first')),
      );
      return;
    }

    String patientId = FirebaseAuth.instance.currentUser!.uid;
    String analysisContent = _textEditingController.text;
    Timestamp uploadTime = Timestamp.now();

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .doc();

    await docRef.set({
      'analysisResult': analysisContent,
      'uploadDate': uploadTime,
      'assignedDoctorId': selectedDoctorId,
    }).then((_) {
      _savedDocumentId = docRef.id;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document saved successfully!')),
      );
      setState(() {
        _isSaved = true;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save document: $error')),
      );
    });
  }

  void _sendToDoctor() async {
    if (_savedDocumentId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No document saved to send')));
      return;
    }

    try {
      String patientId = FirebaseAuth.instance.currentUser!.uid;
      await patientServices.sendDocumentToDoctor(patientId, _savedDocumentId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document sent to doctor for review')),
      );
      // Sikeres küldés után visszanavigálunk a PatientHomeScreen-re
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => PatientHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending document to doctor: $e')),
      );
    }
  }

  // Ez a függvény hívódik meg, amikor a felhasználó kiválaszt egy orvost
  void _onDoctorSelected(String? doctorId) {
    setState(() {
      selectedDoctorId = doctorId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Result'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter analysis result here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    // Hozzáadva, hogy a label és a dropdown egymás mellett legyen
                    child: Text('Select a doctor: ',
                        style: TextStyle(fontSize: 16.0)),
                  ),
                  Expanded(
                    // Hozzáadva, hogy a dropdown teljes szélességét használja
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDoctorId,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDoctorId = newValue;
                        });
                      },
                      items: doctorsList.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['id'],
                          // Létrehozunk egy saját widgetet, amely tartalmazza a checkbox-ot és a szöveget
                          child: Row(
                            children: [
                              Text(doctor['name']),
                              Checkbox(
                                value: selectedDoctorId == doctor['id'],
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedDoctorId = doctor['id'];
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            //buttons
            if (!_isSaved)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _saveDocument,
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
            if (_isSaved)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _sendToDoctor,
                  icon: Icon(Icons.send),
                  label: Text('Send to Doctor'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary,
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
