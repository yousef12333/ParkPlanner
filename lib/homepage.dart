import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding_platform_interface/geocoding_platform_interface.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  late List<Location> _locations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locations = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchAndNavigate() async {
    // get current location
    final currentLocation = await Geolocator.getCurrentPosition();
    final currentLatLng =
        LatLng(currentLocation.latitude, currentLocation.longitude);

    setState(() {
      _isLoading = true;
    });
    try {
      final query = _searchController.text;
      final response =
          await GeocodingPlatform.instance.locationFromAddress(query);

      setState(() {
        _locations = response;
        _isLoading = false;
      });
      if (_locations.isNotEmpty) {
        final first = _locations.first;
        _mapController.move(
          LatLng(first.latitude, first.longitude),
          16.0,
        );
      }
    } catch (e) {
      setState(() {
        _locations = [];
        _isLoading = false;
      });
      print('Error searching location: $e');
    }
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
                  color:
                      const Color.fromARGB(255, 222, 222, 222).withOpacity(0.5),
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
                  onPressed: _searchAndNavigate,
                  child: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // FlutterMap widget
          Container(
              height: MediaQuery.of(context).size.height / 1.42,
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(51.260197, 4.402771), // Antwerpen
                    zoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                  ])),
        ],
      ),
      //Navigation
    );
  }
}
/* bottomNavigationBar: SizedBox(
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
      ), */ 