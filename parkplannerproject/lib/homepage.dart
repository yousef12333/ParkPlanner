import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    //title: 'hello this is the homepage'
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamed('/login');
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome bij ParkPlanner!'),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
        ]),
      ),
    );
  }
}
