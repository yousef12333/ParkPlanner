import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();
  List<Marker> _markers = [];
  Position? _currentPosition;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  String _theme = 'light';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadUserParkingSpots();
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

  void _loadCurrentLocation() async {
    bool locationPermissionGranted = await _checkLocationPermission();
    if (locationPermissionGranted) {
      Position? currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (currentPosition != null) {
        setState(() {
          _currentPosition = currentPosition;
          _markers.add(
            Marker(
              point: LatLng(
                currentPosition.latitude,
                currentPosition.longitude,
              ),
              builder: (_) => const Icon(Icons.location_on),
            ),
          );
        });

        _mapController.move(
          LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
          13.0,
        );
      }
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _searchAddress(String address) async {
    LatLng? latLng = await _getLatLngFromAddress(address);
    if (latLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not found'),
        ),
      );
      return;
    }
    _mapController.move(latLng, 18.0);
    setState(() {
      _markers = [
        Marker(
          point: latLng,
          builder: (_) => const Icon(Icons.location_on),
        ),
      ];
    });
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&addressdetails=1&limit=1'));
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isNotEmpty) {
        final result = results.first;
        final lat = double.tryParse(result['lat']);
        final lon = double.tryParse(result['lon']);
        if (lat != null && lon != null) {
          return LatLng(lat, lon);
        }
      }
    }
    return null;
  }

  void _loadUserParkingSpots() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('parking')
          .where('email', isEqualTo: user.email)
          .get();
      List<Marker> userMarkers = [];

      snapshot.docs.forEach((doc) {
        double latitude = doc['latitude'];
        double longitude = doc['longitude'];

        userMarkers.add(
          Marker(
            point: LatLng(latitude, longitude),
            builder: (_) => const Icon(Icons.local_parking),
          ),
        );
      });

      setState(() {
        _markers.addAll(userMarkers);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _theme == 'dark';
    return Scaffold(
        backgroundColor:
            isDarkTheme ? const Color.fromARGB(255, 52, 52, 52) : Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Home',
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
                          FirebaseAuth.instance.signOut();
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: const Icon(
                          Icons.logout,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDarkTheme
                            ? Colors.white
                            : const Color.fromARGB(255, 52, 52, 52),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Zoek locatie',
                        hintStyle: TextStyle(
                          color: isDarkTheme
                              ? Colors.white
                              : Colors.black.withOpacity(0.6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: isDarkTheme
                                ? Colors.white
                                : const Color.fromARGB(255, 52, 52, 52),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: isDarkTheme
                                ? Colors.white
                                : const Color.fromARGB(255, 52, 52, 52),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _searchAddress(_searchController.text);
                    },
                    child: const Text('Zoek'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.44,
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude)
                      : LatLng(51.260197, 4.402771),
                  zoom: 13.0,
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: _markers,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _toggleTheme,
                child: Text(
                  'Schakel over naar ${isDarkTheme ? 'licht' : 'donker'} achtergrondkleur',
                  style: TextStyle(
                    color: isDarkTheme
                        ? Colors.white
                        : const Color.fromARGB(255, 52, 52, 52),
                  ),
                ),
              ),
            ),
          ],
        ),
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
