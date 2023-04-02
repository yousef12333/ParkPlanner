import 'dart:developer';
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
      appBar: AppBar(title: const Text('Voeg een wagen toe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Kentekenplaatnummer'),
                onSaved: (value) => licensePlateNumber = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Geef een kentekenplaatnummer in!' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Merk'),
                onSaved: (value) => brand = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Geef een merk in!' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Model'),
                onSaved: (value) => model = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Geef een model in' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bijnaam'),
                onSaved: (value) => nickname = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Geef een bijnaam in' : null,
              ),
              if (!_emailDoesNotExist)
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Bewaren'),
                ),
              if (_emailDoesNotExist)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Email niet gevonden. Logt u alstublieft in.',
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
