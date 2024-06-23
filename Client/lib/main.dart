import 'package:flutter/material.dart';
import 'screens/AuthScreens/SplashScreen.dart';
import 'screens/AuthScreens/LoginScreen.dart';
import 'screens/AuthScreens/RegisterScreen.dart';
import 'screens/DoctorScreens/DoctorHomeScreen.dart';
import 'screens/DoctorScreens/Profile/DoctorProfileScreen.dart';
import 'screens/PatientScreens/PatientHomeScreen.dart';
import 'screens/PatientScreens/Profile/PatientProfileScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DoctorGPT App',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // splash
      routes: {
        // routing logika
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/doctor_home': (context) => DoctorHomeScreen(),
        '/patient_home': (context) => const PatientHomeScreen(),
        '/doctor_profile': (context) => DoctorProfileScreen(),
        '/patient_profile': (context) => PatientProfileScreen(),
      },
    );
  }
}
