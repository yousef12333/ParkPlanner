import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  _EditPasswordPageState createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureTextNew = true;
  String _eyeImage = 'Eye_open.jpg';
  String _eyeImageNew = 'Eye_open.jpg';

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _eyeImage = _obscureText ? 'Eye_open.jpg' : 'Eye_closed.jpg';
    });
  }

  void _toggleObscureTextNew() {
    setState(() {
      _obscureTextNew = !_obscureTextNew;
      _eyeImageNew = _obscureTextNew ? 'Eye_open.jpg' : 'Eye_closed.jpg';
    });
  }

  Future<void> _changePassword() async {
    try {
      setState(() {
        _isLoading = true;
      });

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _oldPasswordController.text.trim(),
      );

      await userCredential.user
          ?.updatePassword(_newPasswordController.text.trim());
      await FirebaseAuth.instance.signOut();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text(
              'Wachtwoord is aangepast. Log in met uw nieuwe wachtwoord.'),
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
    } on FirebaseAuthException catch (error) {
      String message = '';
      if (error.code == 'user-not-found') {
        message =
            'Gebruiker niet gevonden. Controleer uw gegevens en probeer het opnieuw.';
      } else if (error.code == 'wrong-password') {
        message =
            'Verkeerde wachtwoord. Controleer uw gegevens en probeer het opnieuw.';
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
                        'Wachtwoord aanpassen',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                              overlayColor: MaterialStateProperty.all<Color>(
                                  Colors.transparent),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Icon(
                              Icons.keyboard_return_rounded,
                              color: Colors.green,
                            ),
                          ),
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
                        children: <Widget>[
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
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
                            controller: _oldPasswordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Oud wachtwoord',
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
                                return 'Geef een wachtwoord met minstens 7 karakters op.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureTextNew,
                            decoration: InputDecoration(
                              labelText: 'Nieuw wachtwoord',
                              border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: InkWell(
                                  onTap: _toggleObscureTextNew,
                                  child: Image.asset(
                                    _eyeImageNew,
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
                            onPressed: _changePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Aanpassen',
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
                                                    BorderRadius.circular(8.0),
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
                                                      decoration: TextDecoration
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
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed('/register');
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
                                                      decoration: TextDecoration
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
                                                  .pushNamed('/login');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed('/login');
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                const Text(
                                                  'Heeft u al een account?',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                GestureDetector(
                                                  child: const Text(
                                                    'Log in',
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 12,
                                                      decoration: TextDecoration
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
                ))
              ]));
  }
}
