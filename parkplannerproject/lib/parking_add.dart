import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
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
  LatLng? _selectedLocation;
  String _countryCity = '';

  MapController _mapController = MapController();

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Parking Space'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('Select Location:', style: TextStyle(fontSize: 18)),
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
                      // Add a marker layer to the map
                      MarkerLayer(
                        markers: [
                          if (_selectedLocation != null)
                            Marker(
                              point: _selectedLocation!,
                              builder: (_) => const Icon(Icons.location_on),
                            ),
                        ],
                      ),
                      // Add a tap handler to the map
                      GestureDetector(
                        onTapUp: (details) => _selectLocation(details),
                        behavior: HitTestBehavior.translucent,
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          onPressed: _zoomIn,
                          child: const Icon(Icons.zoom_in),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: _zoomOut,
                          child: const Icon(Icons.zoom_out),
                        ),
                      ],
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (hours)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitParkingSpace,
              child: const Text('Submit Parking Space'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom - 1);
  }

  // momenteel redelijk innacuraat, maar dat komt omdat de coordinaten van de map niet overeenkomen met de coordinaten van de echte wereld
  Future<void> _selectLocation(TapUpDetails details) async {
    final double width = details.localPosition.dx;
    final double height = details.localPosition.dy;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    const double centerScreenLatitude = 51.2194;
    const double centerScreenLongitude = 4.4025;

    // Calculate the distance from the center of the screen to the top-left corner
    final double diagonalDistance =
        sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    final double distanceFromCenter = diagonalDistance / 2.0;

    // Calculate the latitude and longitude of the top-left corner of the screen
    final double topLeftLatitude =
        centerScreenLatitude + (distanceFromCenter * cos(pi / 4)) / 111319.9;
    final double topLeftLongitude = centerScreenLongitude -
        (distanceFromCenter * sin(pi / 4)) /
            (111319.9 * cos(centerScreenLatitude));

    // Calculate the latitude and longitude of the tapped location
    final double tappedLatitude = topLeftLatitude -
        (height / screenHeight) * (diagonalDistance / 111319.9);
    final double tappedLongitude = topLeftLongitude +
        (width / screenWidth) *
            (diagonalDistance / (111319.9 * cos(tappedLatitude)));

    final LatLng selectedLocation = LatLng(tappedLatitude, tappedLongitude);

    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${selectedLocation.latitude}&lon=${selectedLocation.longitude}&format=jsonv2'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final String country = json['address']['country'] ?? '';
      final String city = json['address']['city'] ??
          json['address']['town'] ??
          json['address']['village'] ??
          '';
      final String street = json['address']['road'] ?? '';
      final String houseNumber = json['address']['house_number'] ?? '';
      final String postcode = json['address']['postcode'] ?? '';

      final String address = '$country, $postcode $city, $street $houseNumber';
      setState(() {
        _selectedLocation = selectedLocation;
        _countryCity = address;
      });
    }
  }

  Future<void> _submitParkingSpace() async {
    final durationText = _durationController.text;
    final duration = int.tryParse(durationText);

    if (_selectedLocation == null || duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location and enter a valid duration'),
        ),
      );
      return;
    }

    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add a parking space'),
        ),
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking space added successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add parking space: $error')),
      );
    }
  }
}
