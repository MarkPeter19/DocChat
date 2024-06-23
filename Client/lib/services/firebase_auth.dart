import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireBaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username, String userType) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? newUser = credential.user;

      if (newUser != null) {
        // saving new user to users collection
        await _firestore.collection('users').doc(newUser.uid).set({
          'email': email,
          'userName': username,
          'userType': userType,
        });

        // creating doctor/patient collections
        if (userType == 'doctor') {
          await _firestore.collection('doctors').doc(newUser.uid).set({});
        } else if (userType == 'patient') {
          await _firestore.collection('patients').doc(newUser.uid).set({});
        }

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      rethrow;
    } catch (e) {
      print(e.toString());
      throw Exception('An unexpected error occurred.');
    }
    return null;
  }

  //login
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print(e.code);
      throw e;
    } catch (e) {
      print(e.toString());
      throw Exception('An unexpected error occurred.');
    }
  }
}
