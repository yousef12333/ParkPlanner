import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final MapController _mapController = MapController();

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
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
                'Voeg een parkeerplaats toe',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          centerTitle: false,
        ),
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
                      zoom: 8.0,
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
                      GestureDetector(
                        onTapUp: (details) => _selectLocation(details),
                        behavior: HitTestBehavior.translucent,
                      ),
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
                decoration: const InputDecoration(
                  labelText: 'Straatnaam',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _houseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Huisnummer',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postcode',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Woonplaats',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Land',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _updateSelectedLocation();
              },
              child: const Text('Update de map'),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Aantal uur parkeerplaats openstellen',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  labelText: 'Extra beschrijving',
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
            const SizedBox(height: 16),
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

  // momenteel redelijk innacuraat, maar dat komt omdat de coordinaten van de map niet overeenkomen met de coordinaten van de echte wereld
  Future<void> _selectLocation(TapUpDetails details) async {
    final width = details.localPosition.dx;
    final height = details.localPosition.dy;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const centerScreenLatitude = 51.2194;
    const centerScreenLongitude = 4.4025;
    final diagonalDistance =
        sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    final distanceFromCenter = diagonalDistance / 2.0;
    final topLeftLatitude =
        centerScreenLatitude + (distanceFromCenter * cos(pi / 4)) / 111319.9;
    final topLeftLongitude = centerScreenLongitude -
        (distanceFromCenter * sin(pi / 4)) /
            (111319.9 * cos(centerScreenLatitude));
    final tappedLatitude = topLeftLatitude -
        (height / screenHeight) * (diagonalDistance / 111319.9);
    final tappedLongitude = topLeftLongitude +
        (width / screenWidth) *
            (diagonalDistance / (111319.9 * cos(tappedLatitude)));
    final selectedLocation = LatLng(tappedLatitude, tappedLongitude);
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
    }
  }

  Future<void> _updateSelectedLocation() async {
    final address =
        '${_countryController.text}, ${_postalCodeController.text} ${_cityController.text}, ${_streetController.text} ${_houseNumberController.text}';
    final selectedLocation = await geocodeAddress(address);
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Adres niet gevonden. Probeer het opnieuw.')));
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
