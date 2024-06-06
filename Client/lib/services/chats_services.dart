import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  // Save chat messages to Firestore
  Future<void> saveChatMessagesToFirestore(String patientId, String doctorId, List<Map<String, dynamic>> messages) async {
    try {
      // Check if there's already a document for the given patient and doctor
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If there's a document, update the messages
        DocumentReference docRef = querySnapshot.docs.first.reference;
        List<Map<String, dynamic>> existingMessages = List.from(querySnapshot.docs.first.data()['messages']);
        existingMessages.addAll(messages);
        await docRef.update({'messages': existingMessages});
      } else {
        // If there's no document, create a new one
        await FirebaseFirestore.instance.collection('chats').add({
          'patientId': patientId,
          'doctorId': doctorId,
          'messages': messages,
        });
      }
    } catch (e) {
      print('Error saving chat messages to Firestore: $e');
    }
  }

  // Get chat messages from Firestore
  Future<List<Map<String, dynamic>>> getChatMessagesFromFirestore(String patientId, String doctorId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> messages = [];
        querySnapshot.docs.first.data()['messages'].forEach((message) {
          messages.add({
            'sender': message['sender'],
            'content': message['content'],
            'timestamp': message['timestamp'].toDate(),
          });
        });
        return messages;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting chat messages from Firestore: $e');
      throw e;
    }
  }
}
