import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  String _eyeImage = 'Eye_open.jpg';

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _eyeImage = _obscureText ? 'Eye_open.jpg' : 'Eye_closed.jpg';
    });
  }

  void _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 5000));
      Navigator.of(context).pushNamed('/home');
    } on FirebaseAuthException catch (error) {
      String message = '';
      if (error.code == 'user-not-found') {
        message =
            'Gebruiker niet gevonden. Controleer uw gegevens en probeer het opnieuw.';
      } else if (error.code == 'wrong-password') {
        message =
            'Verkeerde password. Controleer uw gegevens en probeer het opnieuw.';
      } else {
        message =
            error.message ?? 'Er is een fout opgetreden. Probeer het opnieuw.';
      }
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        '    Log in',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
                              ),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return 'Geef alstublieft een correcte email op.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Wachtwoord',
                                border: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black)),
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
                                  return 'Geef een wachtwoord met minstens 7 karakters op.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Inloggen',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                    margin: const EdgeInsets.only(top: 25.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                          fit: FlexFit.tight,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 130.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    '/edit_information');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/edit_information');
                                                    },
                                                    icon: const Icon(
                                                      Icons.person,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Wilt u uw gebruikersgegevens aanpassen?',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: const Text(
                                                      'Wijzig gebruikersgegevens',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 130.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pushNamed('/register');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/register');
                                                    },
                                                    icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Heeft u nog geen account?',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: const Text(
                                                      'Creëer je account',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.tight,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                minHeight: 130.0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    '/edit_password');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/edit_password');
                                                    },
                                                    icon: const Icon(
                                                      Icons.lock,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Wilt u uw wachtwoord aanpassen?',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    child: const Text(
                                                      'Wijzig wachtwoord',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]));
  }
}
