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

  Future<String> getDoctorName(String doctorId) async {
    try {
      // Orvos adatainak lekérdezése a 'doctors' kollekcióból
      DocumentSnapshot doctorData =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorData.exists && doctorData.data() is Map) {
        final data = doctorData.data() as Map<String, dynamic>;
        return data['fullName'] ?? "Unknown";
      } else {
        return "Unknown";
      }
    } catch (e) {
      print('Error fetching doctor name: $e');
      return "Unknown";
    }
  }

  //address
  Future<String> getDoctorAddress(String doctorId) async {
    try {
      // Az orvos címének lekérése a 'doctors' kollekcióból
      DocumentSnapshot doctorData =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorData.exists && doctorData.data() is Map) {
        final data = doctorData.data() as Map<String, dynamic>;
        return data['address'] ?? "Unknown";
      } else {
        return "Unknown";
      }
    } catch (e) {
      print('Error fetching doctor address: $e');
      return "Unknown";
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

  // doctor adatok lekérdezése
  Future<Map<String, dynamic>> fetchDoctorData(String doctorId) async {
    try {
      DocumentSnapshot doctorSnapshot =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorSnapshot.exists && doctorSnapshot.data() is Map) {
        return doctorSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Doctor data not found');
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      throw Exception('Error fetching patient data');
    }
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

  // Fetch all doctor data by doctorId
  Future<Map<String, dynamic>> getAllDoctorDatas(String doctorId) async {
    try {
      DocumentSnapshot doctorData =
          await _firestore.collection('doctors').doc(doctorId).get();

      if (doctorData.exists && doctorData.data() is Map) {
        return doctorData.data() as Map<String, dynamic>;
      } else {
        throw Exception('Doctor data not found');
      }
    } catch (e) {
      print('Error fetching all doctor datas: $e');
      throw Exception('Error fetching all doctor datas');
    }
  }

  //save doctor datas
  Future<void> saveDoctorDatas(String doctorId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update(data);
    } catch (e) {
      print('Error saving doctor data: $e');
      throw Exception('Error saving doctor data');
    }
  }

  //fetch patient contact requests for items
  Future<List<DocumentSnapshot>> fetchContactRequests(String doctorId) async {
    try {
      QuerySnapshot requestsSnapshot = await _firestore
          .collection('contactRequests')
          .where('doctorId', isEqualTo: doctorId)
          .where('isAccepted', isEqualTo: false)
          .get();

      return requestsSnapshot.docs;
    } catch (e) {
      print('Error fetching contact requests: $e');
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyPatients(String doctorId) async {
    List<Map<String, dynamic>> patients = [];
    try {
      // Lekérjük az elfogadott kapcsolatfelvételi kérelmeket
      QuerySnapshot requestSnapshot = await _firestore
          .collection('contactRequests')
          .where('doctorId', isEqualTo: doctorId)
          .where('isAccepted', isEqualTo: true)
          .get();

      // Az elfogadott kapcsolatfelvételi kérésekhez tartozó páciensek id-jainak lekérdezése
      List<String> acceptedPatientIds = requestSnapshot.docs
          .map<String>((doc) => doc['patientId'] as String)
          .toList();

      // A páciensek adatainak lekérése a kapcsolatfelvételi kéréseik alapján
      QuerySnapshot patientSnapshot = await _firestore
          .collection('patients')
          .where(FieldPath.documentId, whereIn: acceptedPatientIds)
          .get();

      for (var doc in patientSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        patients.add({
          'id': doc.id,
          'name': data['name'],
          'address': data['address'],
          'profilePictureURL': data['profilePictureURL'],
          'birthDate': data['birthDate'],
          'gender': data['gender'],
          'height': data['height'],
          'weight': data['weight'],
          'symptoms': data['symptoms'],
          'medicalHistory': data['medicalHistory'],
          'currentTreatments': data['currentTreatments'],
          'allergies': data['allergies'],
          'smoker': data['smoker'],
          'alcohol': data['alcohol'],
        });
      }
      return patients;
    } catch (e) {
      print('Error fetching my patients: $e');
      throw Exception('Error fetching my patients');
    }
  }

  // Elutasítja vagy elfogadja a kapcsolatfelvételi kérelmet
  Future<void> updateContactRequestStatus(
      String requestId, bool isAccepted) async {
    try {
      await _firestore.collection('contactRequests').doc(requestId).update({
        'isAccepted': isAccepted,
      });
    } catch (e) {
      print('Error updating contact request status: $e');
      throw Exception('Error updating contact request status');
    }
  }

  // Itt definiálhatsz több függvényt is
}
