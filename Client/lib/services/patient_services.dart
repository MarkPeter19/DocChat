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

  // A beteghez rendelt orvos azonosítójának lekérdezése
  Future<String> getAssignedDoctorIdForDocument(
      String patientId, String documentId) async {
    DocumentSnapshot documentSnapshot = await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .doc(documentId)
        .get();

    if (documentSnapshot.exists && documentSnapshot.data() is Map) {
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      return data['assignedDoctorId'] ?? "No assigned doctor";
    } else {
      throw Exception('Assigned doctor ID not found for document');
    }
  }

  // A dokumentum forDoctorReview mezőjének beállítása true-ra
  Future<void> sendDocumentToDoctor(String patientId, String documentId) async {
    await _firestore
        .collection('patients')
        .doc(patientId)
        .collection('documents')
        .doc(documentId)
        .update({'forDoctorReview': true});
  }

  //fetch doctors
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    List<Map<String, dynamic>> doctors = [];
    QuerySnapshot snapshot = await _firestore.collection('doctors').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      doctors.add({
        'name': data['fullName'],
        'id': doc.id,
      });
    }
    return doctors;
  }

  // Itt definiálhatsz több függvényt is, például:
}
