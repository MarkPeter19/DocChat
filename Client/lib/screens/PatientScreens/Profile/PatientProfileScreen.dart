import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/services/patient_services.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:doctorgpt/screens/PatientScreens/Profile/EditPatientProfileScreen.dart';

class PatientProfileScreen extends StatefulWidget {
  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final PatientServices _patientServices = PatientServices();

  String _name = '';
  String _email = '';
  String _profileImageUrl = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
    _fetchPatientUserName();
  }

  void _fetchPatientDetails() async {
    var details =
        await _patientServices.fetchPatientDetails(_auth.currentUser!.uid);
    setState(() {
      _name = details['name']!;
      _email = details['email']!;
      _profileImageUrl = details['profilePictureURL']!;
    });
  }

  void _fetchPatientUserName() async {
    var username = await _patientServices.fetchPatientUserName();
    setState(() {
      _username = username;
    });
  }

  //log out
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  //delete
  Future<void> _deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error deleting account'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _uploadProfilePicture() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Feltöltés előkészítése
      File imageFile = File(pickedFile.path);
      String fileName = Path.basename(imageFile.path);
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profilePictures/${_auth.currentUser!.uid}/$fileName');

      // Kép feltöltése
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        // URL cím lekérdezése
        String downloadUrl = await storageReference.getDownloadURL();

        // URL cím mentése a Firestore-ban
        await _firestore
            .collection('patients')
            .doc(_auth.currentUser!.uid)
            .update({
          'profilePictureURL': downloadUrl,
        });

        // Profil kép frissítése az UI-on
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      }).catchError((error) {
        print('Hiba a kép feltöltése közben: $error');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 26)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // profile picture
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: _profileImageUrl.isNotEmpty
                                    ? NetworkImage(_profileImageUrl)
                                    : null,
                                child: _profileImageUrl.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 70,
                                        color: Colors.grey.shade800,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: -10,
                                right: -8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Color.fromARGB(255, 47, 221, 137),
                                    size: 40,
                                  ),
                                  onPressed: _uploadProfilePicture,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          //username
                          Center(
                            child: Text(
                              _username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 12,
                          ),

                          //datas
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Full Name:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _name,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Text(
                                'Email Address:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          //edit profile button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      EditPatientProfileScreen()));
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              textStyle: const TextStyle(fontSize: 16),
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //log out and delete buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 252, 171, 50),
                    textStyle: const TextStyle(fontSize: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 10), // Több hely az alsó gombok között
                ElevatedButton.icon(
                  onPressed: _deleteAccount,
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 255, 106, 96),
                    textStyle: const TextStyle(fontSize: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
