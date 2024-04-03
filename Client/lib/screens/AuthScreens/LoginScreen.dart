import 'package:doctorgpt/services/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/screens/DoctorScreens/DoctorHomeScreen.dart';
import '/screens/PatientScreens/PatientHomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FireBaseAuthService _authService = FireBaseAuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //---login----
  
  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _authService.loginWithEmailAndPassword(email, password);
      if (user != null) {
        // Itt ellenőrizzük a felhasználó típusát és navigálunk a megfelelő képernyőre.
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        var userType = userDoc.data()?['userType'];
        if (userType == 'doctor') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => DoctorHomeScreen()),
          );
        } else if (userType == 'patient') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => PatientHomeScreen()),
          );
        }
      } else {
        // Hiba kezelese, ha a user null
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
      }
    } on FirebaseAuthException catch (e) {
      // Firebase Auth hibak kezelese
      String errorMessage = 'Login error, please try again';;
      if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided for that user';
    } else if (e.code == 'invalid-email') {
      errorMessage = 'The email address is badly formatted.';
    }

      // Handle other errors
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Failed'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
  


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 60.0),
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                child: Text('Login'),
                onPressed: _login, // Bejelentkezés kezelése
              ),
              TextButton(
                child: Text('Don\'t have an account? Register here'),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed('/register'); // navigacio a RegisterScreen-hez
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
