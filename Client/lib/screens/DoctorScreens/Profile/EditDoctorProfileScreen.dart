import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorgpt/services/doctor_services.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({Key? key}) : super(key: key);

  @override
  _EditDoctorProfileScreenState createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final DoctorServices _doctorServices = DoctorServices();

  late TextEditingController _fullNameController;
  late TextEditingController _specializationController;
  late TextEditingController _clinicController;
  late TextEditingController _addressController;
  late TextEditingController _experienceController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _specializationController = TextEditingController();
    _clinicController = TextEditingController();
    _addressController = TextEditingController();
    _experienceController = TextEditingController();
    _aboutController = TextEditingController();
    _fetchDoctorDetails();
  }

  void _fetchDoctorDetails() async {
    var details =
        await _doctorServices.getAllDoctorDatas(_auth.currentUser!.uid);
    setState(() {
      _fullNameController.text = details['fullName'] ?? '';
      _specializationController.text = details['specialization'] ?? '';
      _clinicController.text = details['clinic'] ?? '';
      _addressController.text = details['address'] ?? '';
      _experienceController.text = details['experience'] ?? '';
      _aboutController.text = details['about'] ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _doctorServices.saveDoctorDatas(
          _auth.currentUser!.uid,
          {
            'fullName': _fullNameController.text,
            'specialization': _specializationController.text,
            'clinic': _clinicController.text,
            'address': _addressController.text,
            'experience': _experienceController.text,
            'about': _aboutController.text,
          },
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _specializationController,
                      decoration:
                          const InputDecoration(labelText: 'Specialization'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your specialization';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _clinicController,
                      decoration: const InputDecoration(labelText: 'Clinic'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your clinic';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _experienceController,
                      decoration:
                          const InputDecoration(labelText: 'Experience'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your experience';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _aboutController,
                      decoration: const InputDecoration(labelText: 'About'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter something about you';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.check),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            const Color.fromARGB(255, 100, 222, 129),
                        textStyle: const TextStyle(fontSize: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
