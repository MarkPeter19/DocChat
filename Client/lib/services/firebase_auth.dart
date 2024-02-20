import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ket fgv az alapvető logika a felhasználók regisztrálásához és bejelentkezéshez az Firebase Authentication segítségével

class FireBaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username, String userType) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? newUser = credential.user;

      if (newUser != null) {
        // letrehozzuk a felhasznaloi dokumentumot a 'users' collection-ben
        await _firestore.collection('users').doc(newUser.uid).set({
          'email': email,
          'userName': username,
          'userType': userType,
        });

        // ha az userType 'doctor' vagy 'patient', letrehozzunk egy dokumentumot
        // a megfelelo collection-ben is
        if (userType == 'doctor') {
          await _firestore.collection('doctors').doc(newUser.uid).set({
            // Itt adhatjuk meg az orvosokhoz szükséges kezdeti adatokat.
          });
        } else if (userType == 'patient') {
          await _firestore.collection('patients').doc(newUser.uid).set({
            // Itt adhatjuk meg a betegekhez szükséges kezdeti adatokat.
          });
        }

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      // Itt már nem nyeljük el a kivételt, hanem továbbdobuk.
      print(e.code);
      throw e;
    } catch (e) {
      // Egyéb kivételek kezelése, ha szükséges.
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
      // Itt már nem nyeljük el a kivételt, hanem továbbdobuk.
      print(e.code);
      throw e;
    } catch (e) {
      // Egyéb kivételek kezelése, ha szükséges.
      print(e.toString());
      throw Exception('An unexpected error occurred.');
    }
  }


}
