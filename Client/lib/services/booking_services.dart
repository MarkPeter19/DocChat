import 'package:cloud_firestore/cloud_firestore.dart';


class BookingServices {
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
          .collection('doctors')
          .doc(doctorId)
          .collection('appointments')
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

  // Check if appointment slot is available
  Future<bool> isAppointmentAvailable({
    required String doctorId,
    required int year,
    required int month,
    required int day,
    required String hourMinute,
  }) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .collection('appointments')
          .doc('$year-$month-$day $hourMinute')
          .get();

      // If document does not exist, slot is available
      return !documentSnapshot.exists;
    } catch (e) {
      // Handle any potential errors here
      print('Error checking appointment availability: $e');
      return false; // Return false in case of error
    }
  }

  //save appointments
  Future<void> saveAppointment({
    required String doctorId,
    required String patientId,
    required int year,
    required int month,
    required int day,
    required String hourMinute,
    required String message,
  }) async {
    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('appointments')
        .add({
      'patientId': patientId,
      'date': {
        'year': year,
        'month': month,
        'day': day,
      },
      'hourMinute': hourMinute,
      'message': message,
    });
  }
}
