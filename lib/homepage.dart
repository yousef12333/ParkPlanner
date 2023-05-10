import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MapController _mapController;
  late TextEditingController _searchController;
  List<Marker> _markers = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();
    _searchController = TextEditingController();

    // Get current position
    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = position;
        _markers.add(
          Marker(
            point: LatLng(position.latitude, position.longitude),
            builder: (_) => const Icon(Icons.location_on),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and title
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search location',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Color.fromARGB(255, 5, 105, 9)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _searchAddress(_searchController.text);
                    },
                    child: const Text('Search'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20.0),

            Container(
                height: MediaQuery.of(context).size.height / 1.42,
                width: MediaQuery.of(context).size.width,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
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
                    )
                  ],
                )),
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
        ));
  }

  void _searchAddress(String address) async {
    LatLng? latLng = await _getLatLngFromAddress(address);
    if (latLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
          builder: (_) => Container(
            child: const Icon(Icons.location_on),
          ),
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
}








/* 

            // rode circel
            /*CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                                51.260197, 4.402771), // center of  Antwerpen
                            radius: 5000,
                            useRadiusInMeter: true,
                            color: Colors.red.withOpacity(0.3),
                            borderColor: Colors.red.withOpacity(0.7),
                            borderStrokeWidth: 2,
                          )
                        ],
                      )*/





                      
 */
