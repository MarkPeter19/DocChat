import 'package:doctorgpt/screens/PatientScreens/CameraScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalDataScreen extends StatefulWidget {
  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  // ha a user visszalep, akkor kitoldodjon a korabban megirt adatokkal
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
  double age = 20;
  double height = 170;
  double weight = 60;
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();

  List<bool> smokingStatusSelections = [true, false, false, false];
  List<bool> alcoholConsumptionSelections = [true, false, false, false];

  List<String> smokingOptions = [
    'No',
    'Former smoker',
    'Passive smoker',
    'Yes'
  ];
  List<String> alcoholOptions = [
    'No',
    'Former drinker',
    'Occasionally',
    'I drink daily'
  ];

  // convert List<Bool> -> string
  String getSelectedOption(List<bool> selections, List<String> options) {
    int selectedIndex = selections.indexWhere((element) => element);
    return options[selectedIndex];
  }

  bool _dataSaved = false;

  //adatok mentese a DB-be
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
        'age': age.toInt(),
        'height': height.toInt(),
        'weight': weight.toInt(),
        'smoker': getSelectedOption(smokingStatusSelections, smokingOptions),
        'alcohol':
            getSelectedOption(alcoholConsumptionSelections, alcoholOptions),
        'medicalHistory': _medicalHistoryController.text,
        'symptoms': _symptomsController.text,
      }, SetOptions(merge: true)).then((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Data saved successfully!')));
        setState(() {
          _dataSaved = true; // Frissítjük az állapotváltozót
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
          age = (data['age'] ?? 20).toDouble();
          height = (data['height'] ?? 170).toDouble();
          weight = (data['weight'] ?? 60).toDouble();
          _medicalHistoryController.text = data['medicalHistory'] ?? '';
          _symptomsController.text = data['symptoms'] ?? '';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Datas', style: TextStyle(fontSize: 32)),
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

              //age
              Text('Age: ${age.round()}', style: TextStyle(fontSize: 20)),
              Slider(
                value: age,
                min: 0,
                max: 100,
                divisions: 100,
                label: age.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    age = value;
                  });
                },
                thumbColor: Color.fromARGB(255, 128, 238, 172),
                activeColor: Color.fromARGB(255, 128, 238, 172),
              ),

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

              //smoking
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Do you smoke?', style: TextStyle(fontSize: 20)),
              ),
              ToggleButtons(
                children: smokingOptions
                    .map((String option) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.8),
                          child: Text(option, style: TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                isSelected: smokingStatusSelections,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < smokingStatusSelections.length;
                        buttonIndex++) {
                      smokingStatusSelections[buttonIndex] =
                          buttonIndex == index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20.0),
                fillColor: Color.fromARGB(255, 248, 208, 9),
                selectedBorderColor: Color.fromARGB(255, 248, 208, 9),
                selectedColor: Color.fromARGB(255, 252, 252, 252),
                borderColor: Color.fromARGB(255, 248, 208, 9),
                borderWidth: 2,
                constraints: BoxConstraints(minHeight: 50.0),
              ),
              SizedBox(height: 20),

              // alcohol consumption
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Do you drink alcohol?',
                    style: TextStyle(fontSize: 20)),
              ),
              ToggleButtons(
                children: alcoholOptions
                    .map((String option) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7.8),
                          child: Text(option, style: TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                isSelected: alcoholConsumptionSelections,
                onPressed: (int index) {
                  setState(() {
                    for (int buttonIndex = 0;
                        buttonIndex < alcoholConsumptionSelections.length;
                        buttonIndex++) {
                      alcoholConsumptionSelections[buttonIndex] =
                          buttonIndex == index;
                    }
                  });
                },
                borderRadius: BorderRadius.circular(20.0),
                fillColor: Color.fromARGB(255, 250, 102, 94),
                selectedBorderColor: Color.fromARGB(255, 232, 90, 82),
                selectedColor: Colors.white,
                borderColor: Color.fromARGB(255, 232, 90, 82),
                borderWidth: 2,
                constraints: BoxConstraints(minHeight: 50.0),
              ),

              // medical history
              TextFormField(
                controller: _medicalHistoryController,
                decoration: InputDecoration(
                    labelText: 'Medical history',
                    labelStyle: TextStyle(fontSize: 20)),
                //onSaved: (value) => medicalHistory = value!,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              // symptoms
              TextFormField(
                controller: _symptomsController,
                decoration: InputDecoration(
                    labelText: 'Do you have any symptoms?',
                    labelStyle: TextStyle(fontSize: 20)),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              
            ],
          ),
        ),
      ),

      // nav bar
      bottomNavigationBar: BottomAppBar(
        height: 65,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (!_dataSaved) // Ha az adatok nem lettek mentve
              ElevatedButton(
                onPressed: _saveDatas,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightGreen,
                  onPrimary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                
                ),
              ),
              if (_dataSaved) // Ha az adatok mentésre kerültek
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CameraScreen()));
                },
                child: Text('Add Analysis Doc'),
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
