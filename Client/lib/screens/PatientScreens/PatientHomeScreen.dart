import 'package:flutter/material.dart';
import '/screens/PatientScreens/PersonalDataScreen.dart';
import '/screens/PatientScreens/PatientProfileScreen.dart';


class AnalysisItem extends StatelessWidget {
  final String doctorName;
  final String message;
  final String date;

  AnalysisItem({
    required this.doctorName,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple, // Az ikon háttérszíne
          child: Icon(Icons.analytics, color: Colors.white), // Az ikon színe
        ),
        title: Text(
          doctorName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Icon(Icons.keyboard_arrow_right),
        onTap: () {
          // Itt kell majd navigálni az AnalysisResponseScreen-re
        },
      ),
    );
  }
}


class PatientHomeScreen extends StatelessWidget {
  final String username =
      "Username"; // Ideiglenes felhasználónév, be kell állítani

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(fontSize: 26)),
        elevation: 0, // AppBar árnyékának eltávolítása
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 40, // Profilkép mérete
              backgroundColor: Colors.grey, // Profilkép háttérszíne
            ),
            SizedBox(height: 16),
            Text(
              'Hi, $username!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientProfileScreen()),
              ),
              child: Text('Edit Profile'),
            ),
            // Orvos válaszai
            Text('Previous analyses:'),
            AnalysisItem(
            doctorName: 'Dr. Doctor message',
            message: 'Short description of the message...',
            date: '2024-04-01',
          ),
          ],
        ),
      ),

      //add doc btn
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic for navigating to Add Doctor screen
        },
        child: Icon(Icons.add),
        tooltip: 'Add Doctor',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
     
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PersonalDataScreen()));
          },
          child: Text('New Analysis'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity,
                50), // Gomb szélességének és magasságának beállítása
          ),
        ),
      ),
    );
  }
}
