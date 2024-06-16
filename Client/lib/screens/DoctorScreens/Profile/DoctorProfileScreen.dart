import 'package:doctorgpt/screens/DoctorScreens/Profile/EditDoctorProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doctorgpt/services/doctor_services.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:doctorgpt/screens/DoctorScreens/Profile/DoctorUserSettingsScreen.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final DoctorServices _doctorServices = DoctorServices();

  String _fullName = '';
  String _specialization = '';
  String _email = '';
  String _profileImageUrl = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
    _fetchDoctorUserName();
  }

  void _fetchDoctorDetails() async {
    var details =
        await _doctorServices.fetchDoctorDetails(_auth.currentUser!.uid);
    setState(() {
      _fullName = details['fullName']!;
      _specialization = details['specialization']!;
      _email = details['email']!;
      _profileImageUrl = details['profilePictureURL']!;
    });
  }

  void _fetchDoctorUserName() async {
    var username = await _doctorServices.fetchDoctorUserName();
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting account')));
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
            .collection('doctors')
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
                                'Specialization:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _specialization,
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
                                      const EditDoctorProfileScreen()));
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
                          const SizedBox(height: 10),
                          //user settings button
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const DoctorUserSettingsScreen()));
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('User Settings'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
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
