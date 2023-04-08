import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parkplannerproject/parking_add.dart';
import 'package:parkplannerproject/user_registration.dart';
import 'package:parkplannerproject/user_login.dart';
import 'car_add.dart';
import 'firebase_options.dart';
import 'package:parkplannerproject/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPlanner',
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegistrationPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/addcar': (context) => const CarAddPage(),
        '/addparking': (context) => const ParkingAdd(),
      },
    );
  }
}
