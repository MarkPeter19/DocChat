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

  // Itt definiálhatsz több függvényt is, például:
  // Future<void> updateUserProfile(String username, String bio) async {...}
  // Future<List<DocumentSnapshot>> fetchUserDocuments() async {...}
}