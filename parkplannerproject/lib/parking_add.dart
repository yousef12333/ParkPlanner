import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ParkingAdd extends StatefulWidget {
  const ParkingAdd({Key? key}) : super(key: key);

  @override
  _ParkingAddState createState() => _ParkingAddState();
}

class _ParkingAddState extends State<ParkingAdd> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();

  LatLng? _selectedLocation;
  String _countryCity = '';
  final user = FirebaseAuth.instance.currentUser;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = _theme == 'dark';
    return Scaffold(
      backgroundColor:
          isDarkTheme ? const Color.fromARGB(255, 52, 52, 52) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              '/ParkPlannerLogo.png',
              width: 120,
              height: 20,
              fit: BoxFit.fill,
            ),
            const SizedBox(width: 9),
            const Text(
              'Voeg een parkeerplaats toe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent),
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
        shape: isDarkTheme
            ? const Border(
                bottom: BorderSide(color: Colors.white, width: 0.5),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Selecteer locatie:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(51.2194, 4.4025),
                      zoom:
                          8.0, //zie notepad file die je opgeslagen hebt in documenten of bureaublad
                      onTap: (tapPosition, LatLng location) =>
                          _selectLocation(location),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          if (_selectedLocation != null)
                            Marker(
                              point: _selectedLocation!,
                              builder: (_) => const Icon(Icons.location_on),
                            ),
                        ],
                      ),
                      //  GestureDetector(
                      //   onTapUp: (details) => _selectLocation(details as LatLng),//error
                      //   behavior: HitTestBehavior.translucent,
                      // ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          FloatingActionButton(
                            onPressed: _zoomIn,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.zoom_in),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton(
                            onPressed: _zoomOut,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.zoom_out),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _countryCity,
              style: const TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _streetController,
                decoration: InputDecoration(
                  labelText: 'Straatnaam',
                  border: const OutlineInputBorder(),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _houseNumberController,
                decoration: InputDecoration(
                  labelText: 'Huisnummer',
                  border: const OutlineInputBorder(),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postcode',
                  border: const OutlineInputBorder(),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Woonplaats',
                  border: const OutlineInputBorder(),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Land',
                  border: const OutlineInputBorder(),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateSelectedLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Update de map'),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Aantal uur parkeerplaats openstellen',
                  border: OutlineInputBorder(
                    borderSide: isDarkTheme
                        ? const BorderSide(color: Colors.white)
                        : const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: isDarkTheme
                        ? const BorderSide(color: Colors.white)
                        : const BorderSide(color: Colors.black),
                  ),
                  labelText: 'Extra beschrijving',
                  enabledBorder: isDarkTheme
                      ? const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 175, 175, 175)),
                        )
                      : null,
                  labelStyle: TextStyle(
                    color: isDarkTheme
                        ? const Color.fromARGB(255, 175, 175, 175)
                        : null,
                  ),
                ),
                style: TextStyle(
                  color: isDarkTheme
                      ? const Color.fromARGB(255, 218, 218, 218)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitParkingSpace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:
                  const Text('Bewaar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: _toggleTheme,
              child: Text(
                'Schakel over naar ${isDarkTheme ? 'licht' : 'donker'} achtergrondkleur',
                style:
                    TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
    );
  }

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  Future<void> _selectLocation(LatLng tappedLocation) async {
    final selectedLocation = tappedLocation;
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${selectedLocation.latitude}&lon=${selectedLocation.longitude}&format=jsonv2'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final country = json['address']['country'] ?? '';
      final city = json['address']['city'] ??
          json['address']['town'] ??
          json['address']['village'] ??
          '';
      final street = json['address']['road'] ?? '';
      final houseNumber = json['address']['house_number'] ?? '';
      final postcode = json['address']['postcode'] ?? '';
      final address = '$country, $postcode $city, $street $houseNumber';
      setState(() {
        _selectedLocation = selectedLocation;
        _countryCity = address;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adres in map gevonden.')));
    }
  }

  Future<void> _updateSelectedLocation() async {
    final address =
        '${_countryController.text}, ${_postalCodeController.text} ${_cityController.text}, ${_streetController.text} ${_houseNumberController.text}';
    final selectedLocation = await geocodeAddress(address);
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adres in input niet gevonden.')));
      return;
    }
    setState(() {
      _selectedLocation = selectedLocation;
      _countryCity = address;
    });
    _mapController.move(_selectedLocation!, _mapController.zoom);
  }

  Future<LatLng?> geocodeAddress(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&addressdetails=1&limit=1'));
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isNotEmpty) {
        final result = results.first;
        final lat = double.parse(result['lat']);
        final lon = double.parse(result['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  void _submitParkingSpace() async {
    final durationText = _durationController.text;
    final duration = int.tryParse(durationText);

    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecteer alsjeblieft de hoeveelheid tijd')),
      );
      return;
    }

    await _updateSelectedLocation();

    if (_selectedLocation == null) return;

    _mapController.move(_selectedLocation!, _mapController.zoom);

    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Log alsjeblieft eerst in om een parkeerplaats toe te voegen')),
      );
      return;
    }

    try {
      await _firestore.collection('parking').add({
        'email': user.email!,
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'duration': duration,
        'created_at': FieldValue.serverTimestamp(),
        'description': _descriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkeerplaats succesvol toegevoegd')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Het is niet gelukt om een parkeerplaats toe te voegen: $error')),
      );
    }
  }
}
