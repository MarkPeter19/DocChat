// doctor_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> fetchDoctorName() async {
    String username = "Unknown";
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists && userData.data() is Map) {
          Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
          username = data['userName'] ?? "No username";
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }

    return username;
  }

  //fetch patient requets for items
  Future<List<Map<String, dynamic>>> fetchPatientRequests(String doctorId) async {
  List<Map<String, dynamic>> requests = [];

  // Először lekérdezzük azokat a pácienseket, akikhez tartozik a megadott orvoshoz rendelt dokumentum
  QuerySnapshot patientsSnapshot = await _firestore.collection('patients').get();

  for (var patient in patientsSnapshot.docs) {
    var patientData = patient.data() as Map<String, dynamic>;
    var patientId = patient.id;

    // Most lekérdezzük a pácienshez tartozó dokumentumokat, amelyek az orvoshoz vannak rendelve
    QuerySnapshot documentSnapshot = await patient.reference
        .collection('documents')
        .where('assignedDoctorId', isEqualTo: doctorId)
        .where('forDoctorReview', isEqualTo: true)
        .get();

    for (var document in documentSnapshot.docs) {
      var documentData = document.data() as Map<String, dynamic>;
      if (documentData != null) {
        Timestamp uploadTimestamp = documentData['uploadDate'] as Timestamp;
        DateTime uploadDate = uploadTimestamp.toDate();
        String formattedUploadDate = DateFormat('yyyy-MM-dd – kk:mm').format(uploadDate);

        // Mivel a páciens adatokat már lekérdeztük, hozzáadhatjuk a kérés listához
        requests.add({
          'patientName': patientData['name'], // A páciens neve
          'documentDate': formattedUploadDate, // A dokumentum feltöltésének ideje
          'documentId': document.id, // A dokumentum azonosítója
        });
      }
    }
  }

  return requests;
}


  // Itt definiálhatsz több függvényt is
}
