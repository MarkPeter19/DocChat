import 'package:doctorgpt/services/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/DoctorScreens/DoctorMainScreen.dart';
import '/screens/PatientScreens/PatientMainScreen.dart';

enum UserType { patient, doctor }

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FireBaseAuthService _auth = FireBaseAuthService();

  UserType _userType = UserType.patient;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String userType = _userType == UserType.doctor ? 'doctor' : 'patient';

    try {
      User? user = await _auth.registerWithEmailAndPassword(
          email, password, username, userType);

      if (user != null) {
        // Sikeres regisztráció után navigálás
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => userType == 'patient'
                ? PatientMainScreen()
                : DoctorMainScreen(),
          ),
        );
      } else {
        // Hiba kezelése, ha a user null
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration failed')));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An unexpected error occurred, please try again.';
      if (e.code == 'email-already-in-use') {
        errorMessage =
            'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }
      // Display an error message
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Registration Failed'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('An unexpected error occurred, please try again')));
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  List<bool> _selections = [
    true,
    false
  ]; // kezdeti kivalasztas a ToggleButtons-hoz (patient/doctor)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Register',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 48.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            Center(
              child: ToggleButtons(
                // user type select: Patient/Doctor
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text('Patient'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text('Doctor'),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selections.length; i++) {
                      _selections[i] = (i == index);
                    }
                    _userType = index == 0 ? UserType.patient : UserType.doctor;
                  });
                },
                isSelected: _selections,
                borderRadius: BorderRadius.circular(35.0),
                fillColor: Theme.of(context).colorScheme.primary,
                selectedBorderColor: Theme.of(context).colorScheme.primary,
                selectedColor: Colors.white,
                borderColor: Theme.of(context).colorScheme.primary,
                borderWidth: 2,
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              child: Text('Register'),
              onPressed: _register,
            ),
            TextButton(
              child: Text('Already have an account? Login here'),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed('/login'); // Navigálj a LoginScreen-hez
              },
            ),
          ],
        ),
      ),
    );
  }
}
