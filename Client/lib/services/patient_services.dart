// patient_services.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PatientServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> fetchUsername() async {
    String username = "Unknown";
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
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


 // A beteghez rendelt orvos azonosítójának lekérdezése
  Future<String> getAssignedDoctorId() async {
    String patientId = _auth.currentUser!.uid;
    DocumentSnapshot patientData = await _firestore.collection('patients').doc(patientId).get();
    if (patientData.exists && patientData.data() is Map) {
      Map<String, dynamic> data = patientData.data() as Map<String, dynamic>;
      return data['assignedDoctorId'] ?? "No assigned doctor";
    } else {
      throw Exception('Assigned doctor ID not found');
    }
  }

  // A dokumentum forDoctorReview mezőjének beállítása true-ra
  Future<void> sendDocumentToDoctor(String patientId, String documentId) async {
    await _firestore.collection('patients')
      .doc(patientId)
      .collection('documents')
      .doc(documentId)
      .update({'forDoctorReview': true});
  }

  // Itt definiálhatsz több függvényt is, például:

}