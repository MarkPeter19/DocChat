import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  //change username
  Future<void> _saveUsername() async {
    String newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('New username cannot be empty!')));
      return;
    }

    User? user = _auth.currentUser;
    String uid = user!.uid;
    await _firestore.collection('users').doc(uid).update({'userName': newUsername}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username updated successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating username')));
    });
  }


  //change password
  Future<void> _changePassword(String currentPassword, String newPassword) async {
    // A jelszó frissítéséhez a felhasználónak újra kell hitelesítenie magát
    User? user = _auth.currentUser;
    AuthCredential credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );

    user.reauthenticateWithCredential(credential).then((value) {
      user.updatePassword(newPassword).then((_) {
        // Sikeres jelszó frissítés
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password updated successfully')));
      }).catchError((error) {
        // Jelszó frissítési hiba kezelése
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating password')));
      });
    }).catchError((error) {
      // Újrahitelesítési hiba
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Current password is incorrect')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting account')));
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontSize: 26)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(26),
        child: Column(
          children: [
            //title
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Profile',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            SizedBox(height: 20),

            //username
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Change username',
              ),
            ),
            SizedBox(height: 20),

            //save username
            ElevatedButton(
              onPressed: _saveUsername,
              child: Text('Save Username'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightGreen, 
                onPrimary: Colors.white, 
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),

            //password
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Enter current password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),

            //new password
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Enter new password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),

            //save password
            ElevatedButton(
              onPressed: () => _changePassword(
                  _currentPasswordController.text, _newPasswordController.text),
              child: Text('Save Password'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green, 
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),

            //log out
            SizedBox(height: 70),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Log Out'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 252, 171, 50),
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 10),

            //delete
            ElevatedButton(
              onPressed: _deleteAccount,
              child: Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 255, 106, 96),
                onPrimary: Colors.white,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

