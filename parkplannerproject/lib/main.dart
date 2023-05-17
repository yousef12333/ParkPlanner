import 'dart:async';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Timer _signOutTimer;
  Key _appKey = UniqueKey(); // Unique key for the app

  @override
  void initState() {
    super.initState();
    _startSignOutTimer();
  }

  @override
  void dispose() {
    _cancelSignOutTimer();
    super.dispose();
  }

  void _startSignOutTimer() {
    const expirationDuration = Duration(seconds: 500);
    _signOutTimer = Timer(expirationDuration, () {
      FirebaseAuth.instance.signOut();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Uw Token is vervallen'),
            content:
                const Text('Uw sessie is vervallen. Log alsjeblieft weer.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    });
  }

  void _cancelSignOutTimer() {
    _signOutTimer.cancel();
  }

  void _resetSignOutTimer() {
    _cancelSignOutTimer();
    _startSignOutTimer();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _appKey,
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            _resetSignOutTimer();
            return MaterialApp(
              key: _appKey,
              initialRoute: '/home',
              routes: {
                '/home': (context) => const HomePage(),
                '/addcar': (context) => const CarAddPage(),
                '/addparking': (context) => const ParkingAdd(),
                '/login': (context) => const LoginPage(),
              },
              onUnknownRoute: (settings) {
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
            _cancelSignOutTimer();
            return MaterialApp(
              key: _appKey,
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
              onUnknownRoute: (settings) {
                if (settings.name == '/login') {
                  return MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                    settings: settings,
                  );
                }
                return null;
              },
            );
          }
        },
      ),
    );
  }
}
