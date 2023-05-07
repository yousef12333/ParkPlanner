import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parkplannerproject/parking_add.dart';
import 'package:parkplannerproject/user_registration.dart';
import 'package:parkplannerproject/user_login.dart';
import 'package:parkplannerproject/edit_password.dart';
import 'package:parkplannerproject/edit_information.dart';
import 'car_add.dart';
import 'firebase_options.dart';
import 'package:parkplannerproject/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signOut();
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
              '/home': (context) => const HomePage(),
              '/addcar': (context) => const CarAddPage(),
              '/addparking': (context) => const ParkingAdd(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/login') {
                return MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                  settings: settings,
                );
              }
              return null;
            },
          );
        } else {
          return MaterialApp(
            initialRoute: '/login',
            routes: {
              '/': (context) => const LoginPage(),
              '/register': (context) => const RegistrationPage(),
              '/login': (context) => const LoginPage(),
              '/edit_password': (context) => const EditPasswordPage(),
              '/edit_information': (context) => const EditInformationPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/register') {
                return MaterialPageRoute(
                  builder: (context) => const RegistrationPage(),
                  settings: settings,
                );
              }
              return null;
            },
          );
        }
      },
    );
  }
}
