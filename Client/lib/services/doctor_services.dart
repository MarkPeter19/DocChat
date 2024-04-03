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
  QuerySnapshot patientSnapshot = await _firestore.collection('patients')
    .where('assignedDoctorId', isEqualTo: doctorId)
    .get();
  
  for (var patientDoc in patientSnapshot.docs) {
    var patientData = patientDoc.data() as Map<String, dynamic>;
    if (patientData != null) {
      QuerySnapshot documentSnapshot = await patientDoc.reference
        .collection('documents')
        .where('forDoctorReview', isEqualTo: true)
        .get();

      for (var document in documentSnapshot.docs) {
        var documentData = document.data() as Map<String, dynamic>;
        if (documentData != null) {
          Timestamp uploadTimestamp = documentData['uploadDate'] as Timestamp;
          DateTime uploadDate = uploadTimestamp.toDate();
          String formattedUploadDate = DateFormat('yyyy-MM-dd – kk:mm').format(uploadDate);
          
          requests.add({
            'patientName': patientData['name'],
            'documentDate': formattedUploadDate,
          });
        }
      }
    }
  }

  return requests;
}


  // Itt definiálhatsz több függvényt is
}
