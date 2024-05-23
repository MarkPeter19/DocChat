// doctor_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DoctorServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Az aktuális orvos azonosítójának lekérdezése
  Future<String> fetchDoctorId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<String> fetchDoctorUserName() async {
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
  Future<List<Map<String, dynamic>>> fetchPatientRequests(
      String doctorId) async {
    List<Map<String, dynamic>> requests = [];

    // Először lekérdezzük azokat a pácienseket, akikhez tartozik a megadott orvoshoz rendelt dokumentum
    QuerySnapshot patientsSnapshot =
        await _firestore.collection('patients').get();

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
          String formattedUploadDate =
              DateFormat('yyyy-MM-dd – kk:mm').format(uploadDate);

          // Mivel a páciens adatokat már lekérdeztük, hozzáadhatjuk a kérés listához
          requests.add({
            'patientName': patientData['name'], // A páciens neve
            'documentDate':
                formattedUploadDate, // A dokumentum feltöltésének ideje
            'documentId': document.id, // A dokumentum azonosítója
            'patientId': patientId,
          });
        }
      }
    }

    return requests;
  }

  // fetch data for patient data details screen
  // Beteg adatok lekérdezése a 'patients' kollekcióból
  Future<Map<String, dynamic>> fetchPatientData(String patientId) async {
    var patientSnapshot =
        await _firestore.collection('patients').doc(patientId).get();
    if (!patientSnapshot.exists) {
      throw Exception('Patient not found');
    }
    return patientSnapshot.data() as Map<String, dynamic>;
  }

// Dokumentum adatok lekérdezése egy betegtől a 'documents' kollekcióból
  Future<Map<String, dynamic>> fetchDocumentData(
      String patientId, String documentId) async {
    DocumentSnapshot documentSnapshot = await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .doc(documentId)
        .get();

    if (!documentSnapshot.exists) {
      throw Exception('Document not found');
    }
    return documentSnapshot.data() as Map<String, dynamic>;
  }

  // fetch doctor profile details
  Future<Map<String, String>> fetchDoctorDetails(String uid) async {
    try {
      // Fetching doctor details from 'doctors' collection
      DocumentSnapshot doctorData =
          await _firestore.collection('doctors').doc(uid).get();
      Map<String, String> details = {};

      if (doctorData.exists && doctorData.data() is Map) {
        final data = doctorData.data() as Map<String, dynamic>;
        details['fullName'] = data['fullName'] ?? "No full name";
        details['specialization'] =
            data['specialization'] ?? "No specialization";
        details['profilePictureURL'] = data['profilePictureURL'] ?? "";
      }

      // Fetching email from 'users' collection
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(uid).get();
      if (userData.exists && userData.data() is Map) {
        final data = userData.data() as Map<String, dynamic>;
        details['email'] = data['email'] ?? "No email";
      }

      return details;
    } catch (e) {
      print('Error fetching doctor details: $e');
      throw Exception('Error fetching doctor details');
    }
  }

  Future<void> updateDoctorDetails(Map<String, String> updates) async {
    User? user = _auth.currentUser;
    if (user != null && updates.isNotEmpty) {
      await _firestore.collection('doctors').doc(user.uid).update(updates);
    }
  }

  // Itt definiálhatsz több függvényt is
}
