import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parkplannerproject/user_registration.dart';
import 'firebase_options.dart';
import 'user_login.dart';

//firestore functioneert als backend

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RegistrationPage(),
    );
  }
}
