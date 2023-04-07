import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  bool _emailDoesNotExist = false;

  late String licensePlateNumber;
  late String brand;
  late String model;
  late String nickname;

  void _submitForm() async {
    final isValid = formKey.currentState?.validate();

    if (!isValid!) {
      return;
    }

    formKey.currentState?.save();
    //aanmaken en gebruik van nieuwe tabel cars
    final carCollectionRef = firestore.collection('cars');
    //controleren of de huidige user al bestaat in de database
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final userCollectionRef = firestore.collection('users');
    final userSnapshot =
        await userCollectionRef.where('email', isEqualTo: userEmail).get();
    final emailExists = userSnapshot.docs.isNotEmpty;

    //logging om te zien of het werkelijk werkt
    debugPrint(emailExists.toString());
    debugPrint(userEmail.toString());
    if (!emailExists) {
      setState(() {
        _emailDoesNotExist = true;
      });
      return;
    }
    try {
      await carCollectionRef.add({
        'licensePlateNumber': licensePlateNumber,
        'brand': brand,
        'model': model,
        'nickname': nickname,
        'userEmail': userEmail,
      });
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

//je moet inloggen als je dit pagina wilt gebruiken, anders geeft het error
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color:
                      const Color.fromARGB(255, 222, 222, 222).withOpacity(0.5),
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
                  'Voeg een wagen toe',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Kentekenplaatnummer',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
            onSaved: (value) => licensePlateNumber = value!,
            validator: (value) =>
                value!.isEmpty ? 'Geef een kentekenplaatnummer in!' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Merk',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
            onSaved: (value) => brand = value!,
            validator: (value) => value!.isEmpty ? 'Geef een merk in!' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
            onSaved: (value) => model = value!,
            validator: (value) => value!.isEmpty ? 'Geef een model in' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            decoration: const InputDecoration(
                labelText: 'Bijnaam',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black))),
            onSaved: (value) => nickname = value!,
            validator: (value) => value!.isEmpty ? 'Geef een bijnaam in' : null,
          ),
          const SizedBox(height: 15),
          if (!_emailDoesNotExist)
            ElevatedButton(
              onPressed: _submitForm,
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
          if (_emailDoesNotExist)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Email niet gevonden. Logt u alstublieft in.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
