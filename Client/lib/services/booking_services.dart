import 'package:cloud_firestore/cloud_firestore.dart';

class BookingServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>?> getBookingStream(
      String doctorId, {required DateTime start, required DateTime end}) async* {
    QuerySnapshot bookingSnapshot = await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('appointments')
        .where('bookingStart', isGreaterThanOrEqualTo: start)
        .where('bookingEnd', isLessThanOrEqualTo: end)
        .get();

    List<Map<String, dynamic>> bookings = [];
    bookingSnapshot.docs.forEach((doc) {
      bookings.add({
        'patientId': doc['patientId'],
        'bookingStart': doc['bookingStart'],
        'bookingEnd': doc['bookingEnd'],
        'message': doc['message'],
      });
    });

    yield bookings;
  }

  //save appointments
  Future<void> uploadBooking({
    required String doctorId,
    required String patientId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
    required String message,
  }) async {
    await _firestore
        .collection('doctors')
        .doc(doctorId)
        .collection('appointments')
        .add({
      'patientId': patientId,
      'bookingStart': bookingStart,
      'bookingEnd': bookingEnd,
      'message': message,
    });
  }
}