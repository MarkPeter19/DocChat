import 'package:doctorgpt/screens/PatientScreens/Home/AddPDFScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDataScreen extends StatefulWidget {
  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  String gender = '';
  DateTime? birthDate; // Modified
  double height = 170;
  double weight = 60;
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _currentTreatmentController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  List<bool> smokingStatusSelections = [true, false, false, false];
  List<bool> alcoholConsumptionSelections = [true, false, false, false];

  List<String> smokingOptions = [
    'No',
    'Former smoker',
    'Passive smoker',
    'Yes, I smoke'
  ];
  List<String> alcoholOptions = [
    'No',
    'Former drinker',
    'Occasionally',
    'I drink daily'
  ];

  String getSelectedOption(List<bool> selections, List<String> options) {
    int selectedIndex = selections.indexWhere((element) => element);
    return options[selectedIndex];
  }

  bool _dataSaved = false;

  void _saveDatas() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      User? currentUser = _auth.currentUser;

      await FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser!.uid)
          .set({
        'name': _nameController.text,
        'gender': gender,
        'birthDate': birthDate,
        'height': height.toInt(),
        'weight': weight.toInt(),
        'smoker': getSelectedOption(smokingStatusSelections, smokingOptions),
        'alcohol':
            getSelectedOption(alcoholConsumptionSelections, alcoholOptions),
        'medicalHistory': _medicalHistoryController.text,
        'symptoms': _symptomsController.text,
        'address': _addressController.text,
        'currentTreatments': _currentTreatmentController.text,
        'allergies': _allergiesController.text,
      }, SetOptions(merge: true)).then((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data saved successfully!')));
        setState(() {
          _dataSaved = true;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save data')));
      });
    }
  }

  void _loadUserData() async {
    User? currentUser = _auth.currentUser;
    try {
      DocumentSnapshot userData =
          await _firestore.collection('patients').doc(currentUser!.uid).get();

      if (userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          gender = data['gender'] ?? '';
          birthDate = data['birthDate'] != null
              ? (data['birthDate'] as Timestamp).toDate() // Modified
              : null;
          height = (data['height'] ?? 170).toDouble();
          weight = (data['weight'] ?? 60).toDouble();
          _medicalHistoryController.text = data['medicalHistory'] ?? '';
          _symptomsController.text = data['symptoms'] ?? '';
          _addressController.text = data['address'] ?? '';
          _currentTreatmentController.text = data['currentTreatments'] ?? '';
          _allergiesController.text = data['allergies'] ?? '';

          int smokingIndex = smokingOptions.indexOf(data['smoker'] ?? 'No');
          smokingStatusSelections = List.generate(
              smokingOptions.length, (index) => index == smokingIndex);

          int alcoholIndex = alcoholOptions.indexOf(data['alcohol'] ?? 'No');
          alcoholConsumptionSelections = List.generate(
              alcoholOptions.length, (index) => index == alcoholIndex);
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _medicalHistoryController.dispose();
    _symptomsController.dispose();
    _addressController.dispose();
    _currentTreatmentController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Datas', style: TextStyle(fontSize: 26)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name:',
                  labelStyle: TextStyle(
                    fontSize: 20,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              //address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                    labelText: 'Address', labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              //gender
              Text('Gender:', style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              ToggleButtons(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Male',
                        style: TextStyle(fontSize: 16),
                      )),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text('Female', style: TextStyle(fontSize: 16))),
                ],
                isSelected: [gender == 'male', gender == 'female'],
                onPressed: (int index) {
                  setState(() {
                    gender = index == 0 ? 'male' : 'female';
                  });
                },
                borderRadius: BorderRadius.circular(35.0),
                fillColor: Theme.of(context).colorScheme.primary,
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                selectedColor: Colors.white,
                borderColor: Theme.of(context).colorScheme.primary,
                borderWidth: 2,
              ),
              SizedBox(height: 20),

              // Birth Date
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: birthDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != birthDate) {
                    setState(() {
                      birthDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Birth Date:',
                      labelStyle: TextStyle(fontSize: 20),
                    ),
                    style: TextStyle(fontSize: 18),
                    controller: TextEditingController(
                        text: birthDate != null
                            ? "${birthDate!.day}/${birthDate!.month}/${birthDate!.year}"
                            : ""),
                    validator: (value) {
                      if (birthDate == null) {
                        return 'Please select your birth date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              //height
              SizedBox(height: 20),
              Text('Height: ${height.round()} cm',
                  style: TextStyle(fontSize: 20)),
              Slider(
                value: height,
                min: 50,
                max: 250,
                divisions: 250,
                label: height.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    height = value;
                  });
                },
                thumbColor: Color.fromARGB(255, 243, 93, 153),
                activeColor: Color.fromARGB(255, 243, 93, 153),
              ),
              //weight
              SizedBox(height: 20),
              Text('Weight: ${weight.round()} kg',
                  style: TextStyle(fontSize: 20)),
              Slider(
                value: weight,
                min: 2,
                max: 200,
                divisions: 200,
                label: weight.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    weight = value;
                  });
                },
                thumbColor: Color.fromARGB(255, 117, 172, 243),
                activeColor: Color.fromARGB(255, 117, 172, 243),
              ),
              SizedBox(height: 20),

              //smoke
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Do you smoke?', style: TextStyle(fontSize: 20)),
              ),
              Wrap(
                spacing: 8.0, // horizontal gap between buttons
                runSpacing: 8.0, // vertical gap between lines
                children: List.generate(smokingOptions.length, (index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < smokingStatusSelections.length;
                            buttonIndex++) {
                          smokingStatusSelections[buttonIndex] =
                              buttonIndex == index;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: smokingStatusSelections[index]
                          ? Color.fromARGB(255, 255, 229, 28) // selected color
                          : Color.fromARGB(255, 252, 252, 252), // default color
                      onPrimary: Colors.black, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(smokingOptions[index]),
                  );
                }),
              ),
              SizedBox(height: 20),

              //alcohol
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Do you drink alcohol?',
                    style: TextStyle(fontSize: 20)),
              ),
              Wrap(
                spacing: 8.0, // horizontal gap between buttons
                runSpacing: 8.0, // vertical gap between lines
                children: List.generate(alcoholOptions.length, (index) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        for (int buttonIndex = 0;
                            buttonIndex < alcoholConsumptionSelections.length;
                            buttonIndex++) {
                          alcoholConsumptionSelections[buttonIndex] =
                              buttonIndex == index;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: alcoholConsumptionSelections[index]
                          ? Color.fromARGB(255, 249, 101, 101) // selected color
                          : Color.fromARGB(255, 252, 252, 252), // default color
                      onPrimary: Colors.black, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: Text(alcoholOptions[index]),
                  );
                }),
              ),

              //medical history
              TextFormField(
                controller: _medicalHistoryController,
                decoration: InputDecoration(
                    labelText: 'Medical history',
                    labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              //symptoms
              TextFormField(
                controller: _symptomsController,
                decoration: InputDecoration(
                    labelText: 'Do you have any symptoms?',
                    labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              //treatments
              TextFormField(
                controller: _currentTreatmentController,
                decoration: InputDecoration(
                    labelText: 'Current/Previous Treatments',
                    labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              //allergies
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                    labelText: 'Allergies and intolerances',
                    labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),

      //nav bar
      bottomNavigationBar: BottomAppBar(
        height: 65,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (!_dataSaved)
                ElevatedButton.icon(
                  onPressed: _saveDatas,
                  icon: Icon(Icons.done_all),
                  label: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              if (_dataSaved)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddPDFScreen()));
                  },
                  icon: Icon(Icons.add_a_photo_outlined),
                  label: Text('Add Medical PDF Doc'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                    onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
