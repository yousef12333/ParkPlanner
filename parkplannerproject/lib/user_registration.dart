import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  late String firstName;
  late String lastName;
  late String email;
  late String phoneNumber;
  late String password;

  bool isLoading = false;
  bool emailExists = false;

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });

    final isValid = formKey.currentState?.validate();

    if (!isValid!) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    formKey.currentState?.save();

    try {
      final existingUser = await auth.fetchSignInMethodsForEmail(email);

      if (existingUser.isNotEmpty) {
        setState(() {
          emailExists = true;
          isLoading = false;
        });
        return;
      }

      final newUser = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestore.collection('users').doc(newUser.user?.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      }); //voeg nog encrypted password aan toe

      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/emptyPage');
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Er is een error!'),
          content: const Text('Er is iets mis. Fix het!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Creëer je account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        leading: SizedBox(
          width: 80,
          height: 30,
          child: Image.asset(
            '/ParkPlannerLogo.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Voornaam',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Geef astublieft uw voornaam op';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          firstName = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Achternaam',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Geef astublieft uw achternaam op';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          lastName = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Telefoonnummer',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty || value.length != 9) {
                            return 'Telefoonnummer moet 9 cijfers lang zijn';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          phoneNumber = value!;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'E-mailadres',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Geef astublieft een geldig email adres op';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email = value!;
                        },
                      ),
                      if (emailExists)
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Email bestaat al. Geef een ander email adres op.',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Wachtwoord',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black))),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 7) {
                            return 'Wachtwoord moet minsten 7 karakters lang zijn';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password = value!;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Aanmelden',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: RichText(
                          text: TextSpan(
                            text: 'Heb je al een account? ',
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Log in',
                                style: const TextStyle(
                                  color: Colors.green,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushNamed('/user_login');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
