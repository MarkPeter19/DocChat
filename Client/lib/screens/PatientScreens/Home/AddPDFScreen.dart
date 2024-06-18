import 'package:doctorgpt/screens/PatientScreens/PatientHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorgpt/components/success_dialog.dart';

class AddPDFScreen extends StatefulWidget {
  @override
  _AddPDFScreenState createState() => _AddPDFScreenState();
}

class _AddPDFScreenState extends State<AddPDFScreen> {
  final PatientServices patientServices = PatientServices();
  UploadTask? task;
  File? file;
  List<Map<String, dynamic>> doctorsList = [];
  String? selectedDoctorId;
  bool _isSelected = false;
  String? _savedDocumentId;
  XFile? _image;

  //select PDF from phone
  Future selectFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      final path = result.files.single.path;
      setState(() => file = File(path!));
      _isSelected = true;
    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  //load doctors
  Future<void> _loadDoctors() async {
    try {
      String patientId = await patientServices.fetchPatientId();
      var fetchedDoctors = await patientServices.fetchMyDoctors(patientId);
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

  void _sendToDoctor() async {
    if (selectedDoctorId == null || file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a doctor and a PDF to send')));
      return;
    }

    // A fájl feltöltési folyamat elindítása:
    try {
      final fileName = file!.path.split('/').last;
      final destination = 'AnalysisPDFs/$fileName';

      task = FirebaseStorage.instance.ref(destination).putFile(file!);
      final snapshot = await task!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      // A fájl elmentése a Firestore-ba, a megadott orvoshoz rendelve:
      String patientId = FirebaseAuth.instance.currentUser!.uid;
      Timestamp uploadTime = Timestamp.now();

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('documents')
          .doc();

      await docRef.set({
        'PDFName': fileName,
        'PDFUrl': urlDownload, // A feltöltött PDF URL-jének mentése
        'uploadDate': uploadTime,
        'assignedDoctorId': selectedDoctorId,
      });

      // A dokumentum azonosítójának elmentése a későbbi felhasználásra:
      _savedDocumentId = docRef.id;
      await patientServices.sendDocumentToDoctor(patientId, _savedDocumentId!);

      // Visszajelzés a felhasználónak:
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuccessDialog(
            message: 'The document was successfully sent to the doctor',
            onPressed: () {
              Navigator.of(context).pop(); // Bezárja az ablakot
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const PatientHomeScreen()));
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during the file upload: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasDoctors = doctorsList.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add PDF Document'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                  'Select a doctor:',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                borderOnForeground: true,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedDoctorId,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                        size: 40,
                      ),
                      onChanged: hasDoctors
                          ? (newValue) {
                              setState(() {
                                selectedDoctorId = newValue;
                              });
                            }
                          : null,
                      items: doctorsList.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['id'],
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['fullName'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      doctor['specialization'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Checkbox(
                                activeColor: Colors.green,
                                value: selectedDoctorId == doctor['id'],
                                onChanged: hasDoctors
                                    ? (bool? value) {
                                        setState(() {
                                          selectedDoctorId = doctor['id'];
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (!hasDoctors)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Get in contact with a doctor',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),

              // PDF
              if (file != null)
                Card(
                  borderOnForeground: true,
                  elevation: 3,
                  child: Column(
                    children: [
                      const Text(
                        'Selected PDF:',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        file!.path.split('/').last,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Image.asset(
                          'lib/assets/pdf_logo.png',
                          height: 200, // Kép magassága
                          width: 200, // Kép szélessége
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                )
              else
                Card(
                  borderOnForeground: true,
                  elevation: 3,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Center(
                        child: Text(
                          "Add a Medical PDF Document",
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.5, // Fix magasság a képnek
                        child: Center(
                          child: _image == null
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'lib/assets/placeholder.png',
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      //SizedBox(height: 10),
                    ],
                  ),
                ),

              const SizedBox(height: 15),
              if (!_isSelected)
                ElevatedButton.icon(
                  onPressed: selectFile,
                  icon: const Icon(Icons.vertical_align_bottom, size: 24),
                  label: const Text('Select PDF'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 255, 198, 11),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              if (_isSelected)
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: selectFile,
                      icon: const Icon(Icons.change_circle, size: 24),
                      label: const Text('Change PDF'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 198, 11),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _sendToDoctor,
                      icon: const Icon(Icons.send, size: 24),
                      label: const Text('Send to Doctor'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
