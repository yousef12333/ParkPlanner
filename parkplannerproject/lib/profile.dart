import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  bool _notificationsEnabledNot = true;
  bool _notificationsEnabledWar = true;

  bool isEditingFirstName = false;
  bool isEditingLastName = false;
  bool isEditingPhoneNumber = false;
  late String userFirstName = '';
  late String userLastName = '';
  late String phoneNumber = '';
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String _theme = 'light';
  @override
  void initState() {
    super.initState();
    _getThemePreference();
    getFullNames().then((_) {
      firstNameController.text = userFirstName;
      lastNameController.text = userLastName;
      phoneNumberController.text = phoneNumber;
    });
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

  Future<void> getFullNames() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (docSnapshot.exists) {
      setState(() {
        userFirstName = docSnapshot.get('firstName');
        userLastName = docSnapshot.get('lastName');
        phoneNumber = docSnapshot.get('phoneNumber');
      });
    }
  }

  Future<void> updatePersonalInformation() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .update({
        'firstName': userFirstName,
        'lastName': userLastName,
        'phoneNumber': phoneNumber,
      });
      print('Gebruikersinformatie succesvol bijgewerkt in de database.');
      showSnackBar('Gebruikersinformatie succesvol bijgewerkt.', Colors.green);
    } catch (e) {
      print(
          'Er is een fout opgetreden bij het bijwerken van de gebruikersinformatie: $e');
      showSnackBar(
          'Er is een fout opgetreden bij het bijwerken van de gebruikersinformatie: $e',
          Colors.red);
    }
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _theme == 'dark';
    return Scaffold(
        backgroundColor:
            isDarkTheme ? const Color.fromARGB(255, 52, 52, 52) : Colors.white,
        body: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkTheme ? Colors.black : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 222, 222, 222)
                        .withOpacity(0.5),
                    spreadRadius: 5.0,
                    blurRadius: 7.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.0,
                    height: 22.0,
                    child: Image.asset(
                      'ParkPlannerLogo.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Profile',
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.green),
                        title: Text(
                          'Voornaam',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: firstNameController,
                                enabled: isEditingFirstName,
                                onChanged: (value) {
                                  setState(() {
                                    userFirstName = value;
                                  });
                                },
                              ),
                            ),
                            if (isEditingFirstName)
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isEditingFirstName = false;
                                  });
                                  await updatePersonalInformation();
                                },
                                icon:
                                    const Icon(Icons.save, color: Colors.green),
                              ),
                            if (!isEditingFirstName)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isEditingFirstName = true;
                                  });
                                },
                                icon:
                                    const Icon(Icons.edit, color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.person, color: Colors.green),
                        title: Text(
                          'Achternaam',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: lastNameController,
                                enabled: isEditingLastName,
                                onChanged: (value) {
                                  setState(() {
                                    userLastName = value;
                                  });
                                },
                              ),
                            ),
                            if (isEditingLastName)
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isEditingLastName = false;
                                  });
                                  await updatePersonalInformation();
                                },
                                icon:
                                    const Icon(Icons.save, color: Colors.green),
                              ),
                            if (!isEditingLastName)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isEditingLastName = true;
                                  });
                                },
                                icon:
                                    const Icon(Icons.edit, color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.green),
                        title: Text(
                          'Telefoonnummer',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: phoneNumberController,
                                enabled: isEditingPhoneNumber,
                                onChanged: (value) {
                                  setState(() {
                                    phoneNumber = value;
                                  });
                                },
                              ),
                            ),
                            if (isEditingPhoneNumber)
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isEditingPhoneNumber = false;
                                  });
                                  await updatePersonalInformation();
                                },
                                icon:
                                    const Icon(Icons.save, color: Colors.green),
                              ),
                            if (!isEditingPhoneNumber)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isEditingPhoneNumber = true;
                                  });
                                },
                                icon:
                                    const Icon(Icons.edit, color: Colors.green),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Preferences and Settings',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              value: _notificationsEnabledNot,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabledNot = value;
                });
              },
            ),
            SwitchListTile(
              title: Text(
                'Warnings',
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              value: _notificationsEnabledWar,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabledWar = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Bewerk Wachtwoord',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
            ListTile(
              title: const Text('Wachtwoord wijzigen'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.green,
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditPasswordPage()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help en Ondersteuning',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Contact opnemen met klantenservice:',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        '003246522071',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'parkplanner@klantenservice.be',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _toggleTheme,
                    child: Text(
                      'Schakel over naar ${isDarkTheme ? 'licht' : 'donker'} achtergrondkleur',
                      style: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Navigation
        bottomNavigationBar: SizedBox(
          height: 60,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
              icon: const Icon(Icons.person),
              color: Colors.green,
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
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
              icon: const Icon(Icons.calendar_today),
              color: Colors.green,
              onPressed: () {
                Navigator.pushNamed(context, '/reservation');
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
          ]),
        ));
  }
}
