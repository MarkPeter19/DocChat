import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getBookedTimeSlots({
    required String doctorId,
    required int year,
    required int month,
    required int day,
  }) async {
    List<String> bookedTimeSlots = [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date.year', isEqualTo: year)
          .where('date.month', isEqualTo: month)
          .where('date.day', isEqualTo: day)
          .get();

      querySnapshot.docs.forEach((doc) {
        bookedTimeSlots.add(doc['hourMinute']);
      });
    } catch (e) {
      // Handle any potential errors here
      print('Error fetching booked time slots: $e');
    }

    return bookedTimeSlots;
  }

  Future<bool> isAppointmentAvailable({
    required String doctorId,
    required int year,
    required int month,
    required int day,
    required String hourMinute,
  }) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date.year', isEqualTo: year)
          .where('date.month', isEqualTo: month)
          .where('date.day', isEqualTo: day)
          .where('hourMinute', isEqualTo: hourMinute)
          .get();

      // Ha nincs találat, akkor az időpont elérhető
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // Kezeljük az esetleges hibákat
      print('Hiba az időpont elérhetőség ellenőrzésekor: $e');
      return false; // Hiba esetén false értékkel térünk vissza
    }
  }

  Future<void> saveAppointment({
    required String doctorId,
    required String patientId,
    required int year,
    required int month,
    required int day,
    required String hourMinute,
    required String message,
    required Timestamp sendTime,
  }) async {
    await _firestore.collection('appointments').add({
      'doctorId': doctorId,
      'patientId': patientId,
      'date': {
        'year': year,
        'month': month,
        'day': day,
      },
      'hourMinute': hourMinute,
      'message': message,
      'sendTime': sendTime,
    });
  }

  // fetch appointments sent by doctor
  Future<List<Map<String, dynamic>>> fetchAppointments({
    required String patientId,
  }) async {
    List<Map<String, dynamic>> appointments = [];

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();

      for (var doc in querySnapshot.docs) {
        var appointmentData = doc.data() as Map<String, dynamic>;
        var doctorId = appointmentData['doctorId'];
        var appointmentId = doc.id; // appointment id

        // check if 'isAccepted' property does'nt exist
        if (!appointmentData.containsKey('isAccepted')) {
          Map<String, dynamic> appointment = {
            'id': appointmentId,
            'doctorId': doctorId,
            'date': {
              'year': appointmentData['date']['year'],
              'month': appointmentData['date']['month'],
              'day': appointmentData['date']['day'],
            },
            'hourMinute': appointmentData['hourMinute'],
            'message': appointmentData['message'],
            'sendTime': appointmentData['sendTime'],
          };

          appointments.add(appointment);
        }
      }

      if (appointments.isEmpty) {
        print('No appointments found for the patient');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }

    return appointments;
  }

  Future<void> acceptAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'isAccepted': true,
      });
    } catch (e) {
      print('Error accepting appointment: $e');
      throw Exception('Error accepting appointment');
    }
  }

  Future<void> declineAppointment(
      String appointmentId, String declineMessage) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'isAccepted': false,
        'declineMessage': declineMessage,
      });
    } catch (e) {
      print('Error declining appointment: $e');
      throw Exception('Error declining appointment');
    }
  }

  //get accepted appointments for patient
  Future<List<DocumentSnapshot>> getAcceptedAppointments(
      String patientId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .where('isAccepted', isEqualTo: true)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching accepted appointments: $e');
      throw Exception('Error fetching accepted appointments');
    }
  }



  //get declined and accepted appointments for doctor
  Future<List<DocumentSnapshot>> getDeclinedAppointmentsforDoctor(
      String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('isAccepted', isEqualTo: false)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching declined appointments: $e');
      throw Exception('Error fetching declined appointments');
    }
  }

  Future<List<DocumentSnapshot>> getAcceptedAppointmentsForDoctor(
      String doctorId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('isAccepted', isEqualTo: true)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error fetching accepted appointments for doctor: $e');
      throw Exception('Error fetching accepted appointments for doctor');
    }
  }


  //reschedule
  
  Future<void> rescheduleAppointment({
  required String doctorId,
  required String patientId,
  required String oldAppointmentId,
  required int oldYear,
  required int oldMonth,
  required int oldDay,
  required String oldHourMinute,
  required int newYear,
  required int newMonth,
  required int newDay,
  required String newHourMinute,
  required String message,
  required Timestamp sendTime,
}) async {
  try {
    // Töröljük az előzőleg visszamondott időpontot
    await _firestore.collection('appointments').doc(oldAppointmentId).delete();

    // Mentjük az új időpontot és üzenetet
    await saveAppointment(
      doctorId: doctorId,
      patientId: patientId,
      year: newYear,
      month: newMonth,
      day: newDay,
      hourMinute: newHourMinute,
      message: message,
      sendTime: sendTime,
    );
  } catch (e) {
    print('Error rescheduling appointment: $e');
    throw Exception('Error rescheduling appointment');
  }
}



}
