import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarAddPage extends StatefulWidget {
  const CarAddPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CarAddPageState createState() => _CarAddPageState();
}

class _CarAddPageState extends State<CarAddPage> {
  final formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  late String licensePlateNumber;
  late String brand;
  late String model;
  late String nickname;

  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _getThemePreference();
  }

  void _getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final email = user?.email ?? 'guest';
    setState(() {
      _theme = prefs.getString('$email-theme') ?? _theme;
    });
  }

  void _setThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    final email = user?.email ?? 'guest';
    prefs.setString('$email-theme', theme);
  }

  void _toggleTheme() {
    final newTheme = _theme == 'light' ? 'dark' : 'light';
    _setThemePreference(newTheme);
    setState(() {
      _theme = newTheme;
    });
  }

  void _submitForm(BuildContext context) {
    final isValid = formKey.currentState?.validate();

    if (!isValid!) {
      return;
    }

    formKey.currentState?.save();
    final carCollectionRef = firestore.collection('cars');
    final userEmail = user!.email;
    carCollectionRef.add({
      'licensePlateNumber': licensePlateNumber,
      'brand': brand,
      'model': model,
      'nickname': nickname,
      'userEmail': userEmail
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uw wagen is succesvol opgeslagen.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Widget build(BuildContext context) {
    final isDarkTheme = _theme == 'dark';

    return MaterialApp(
        theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 22,
                  child: Image.asset(
                    '/ParkPlannerLogo.png',
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Voeg een wagen toe',
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
                        Navigator.pushNamed(context, '/home');
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[300]!,
                      width: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Kentekenplaatnummer',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey))),
                    onSaved: (value) => licensePlateNumber = value!,
                    validator: (value) => value!.isEmpty
                        ? 'Geef een kentekenplaatnummer in!'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Merk',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    onSaved: (value) => brand = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Geef een merk in!' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Model',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    onSaved: (value) => model = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Geef een model in' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Bijnaam',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black))),
                    onSaved: (value) => nickname = value!,
                    validator: (value) =>
                        value!.isEmpty ? 'Geef een bijnaam in' : null,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Bewaren',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _toggleTheme,
                    child: Text(
                      'Schakel over naar ${isDarkTheme ? 'licht' : 'donker'} achtergrondkleur',
                      style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.home),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.directions_car),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/addcar');
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.add_location),
                  color: Colors.green,
                  onPressed: () {
                    Navigator.pushNamed(context, '/addparking');
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
