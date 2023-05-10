import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parkplannerproject/parking_add.dart';
import 'package:parkplannerproject/profilepage.dart';
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          return MaterialApp(
            initialRoute: '/home',
            routes: {
              '/home': (context) => HomePage(),
              '/addcar': (context) => const CarAddPage(),
              '/profile': (context) => const ProfilePage(),
              '/addparking': (context) => const ParkingAdd(),
            },
          );
        } else {
          return MaterialApp(
            initialRoute: '/login',
            routes: {
              '/': (context) => const LoginPage(),
              '/register': (context) => const RegistrationPage(),
              '/login': (context) => const LoginPage(),
            },
          );
        }
      },
    );
  }
}
