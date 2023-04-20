import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  late String firstName;
  late String lastName;
  late String email;
  late String phoneNumber;
  late String password;
  bool _obscureText = true;
  String _eyeImage = 'Eye_open.jpg'; //zorg ervoor dat de code hieronder werkt.
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _eyeImage = _obscureText ? 'Eye_open.jpg' : 'Eye_closed.jpg';
    });
  }

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
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 222, 222, 222)
                            .withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 22,
                        child: Image.asset(
                          '/ParkPlannerLogo.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Creëer je account',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Wachtwoord',
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: InkWell(
                              onTap: _toggleObscureText,
                              child: Image.asset(
                                _eyeImage,
                                width: 10.0,
                                height: 10.0,
                              ),
                            ),
                          ),
                        ),
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
                                    Navigator.of(context).pushNamed(
                                        '/login'); //google the error en los op
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
