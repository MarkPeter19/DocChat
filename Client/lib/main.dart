import 'package:flutter/material.dart';
import 'screens/AuthScreens/SplashScreen.dart';
import 'screens/AuthScreens/LoginScreen.dart';
import 'screens/AuthScreens/RegisterScreen.dart';
import 'screens/DoctorScreens/DoctorHomeScreen.dart';
import 'screens/DoctorScreens/DoctorMainScreen.dart';
import 'screens/DoctorScreens/DoctorProfileScreen.dart';
import 'screens/PatientScreens/PatientHomeScreen.dart';
import 'screens/PatientScreens/PatientProfileScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoctorGPT App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Kezdő képernyő beállítása
      routes: {
        // routing logika
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/doctor_home': (context) => DoctorHomeScreen(),
        '/patient_home': (context) => PatientHomeScreen(),
        '/doctor_main' :(context) => DoctorMainScreen(),
        '/doctor_profile' :(context) => DoctorProfileScreen(),
        '/patient_profile' :(context) => PatientProfileScreen(),
      },
    );
  }
}
