import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReservationsPage extends StatefulWidget {
  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<DocumentSnapshot> _reservations = [];
  bool _showData = false;
  bool _showParkingSlots =
      false; // Added variable to track parking slots visibility
  String _currentUserEmail = '';
  int _selectedParkingIndex = -1;
  DocumentReference? _selectedReservationRef;
  bool _successMessageVisible = false;
  bool _errorMessageVisible = false;
  String _message = '';

  String _selectedPaymentMethod = '';
  TextEditingController _amountController = TextEditingController();
  TextEditingController _cardNumberController = TextEditingController();

  final List<String> _paymentMethods = [
    'Visa',
    'MasterCard',
    'American Express',
    'PayPal',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
    _restoreReservationData();
  }

  Future<void> _getCurrentUserEmail() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserEmail = currentUser.email!;
      });
    }
  }

  Future<void> _restoreReservationData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Haal de opgeslagen gegevens op uit de lokale opslag
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? selectedParkingIndex = prefs.getInt('selectedParkingIndex');
      String? selectedReservationId = prefs.getString('selectedReservationId');

      if (selectedParkingIndex != null && selectedReservationId != null) {
        setState(() {
          _selectedParkingIndex = selectedParkingIndex;
        });

        DocumentSnapshot reservationSnapshot = await _firestore
            .collection('reservations')
            .doc(selectedReservationId)
            .get();
        setState(() {
          _selectedReservationRef = reservationSnapshot.reference;
        });
      }
    }
  }

  Future<void> fetchReservations() async {
    if (_showParkingSlots) {
      setState(() {
        _showParkingSlots = false; // Close parking slots list
      });
      return;
    }

    QuerySnapshot snapshot = await _firestore.collection('parking').get();
    setState(() {
      _reservations = snapshot.docs
          .where((reservation) => reservation['email'] == _currentUserEmail)
          .toList();
      _showData = true;
      _showParkingSlots = true; // Open parking slots list
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    String apiUrl =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String address = data['display_name'];
        return address;
      }
    } catch (e) {
      print('Error: $e');
    }

    return 'Address not found';
  }

  Future<bool> checkParkingAvailability(String startAt) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('start_at', isEqualTo: startAt)
        .get();

    return snapshot.docs
        .isEmpty; // Return true if no reservations exist for the specified start time
  }

  void chooseParkingSlot(int index) async {
    if (_selectedParkingIndex != index) {
      if (_selectedReservationRef != null) {
        // Toon een dialoogvenster om de gebruiker te vragen of hij wil doorgaan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Bevestigen'),
              content:
                  Text('Wil je doorgaan en de vorige reservering verwijderen?'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Sluit het dialoogvenster en ga door met het selecteren van de nieuwe parkeerplaats
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedParkingIndex = index;
                    });
                    _deletePreviousReservation();
                  },
                  child: Text('Ja'),
                ),
                TextButton(
                  onPressed: () {
                    // Sluit het dialoogvenster zonder wijzigingen aan te brengen
                    Navigator.of(context).pop();
                  },
                  child: Text('Nee'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _selectedParkingIndex = index;
        });
      }
    }
  }

  void _deletePreviousReservation() async {
    await _selectedReservationRef!.delete();
    _selectedReservationRef = null;
  }

  void reserveParking() async {
    if (_selectedParkingIndex != -1) {
      DocumentSnapshot selectedParking = _reservations[_selectedParkingIndex];

      String address = await getAddressFromCoordinates(
          selectedParking['latitude'], selectedParking['longitude']);
      String startAt = selectedParking['start_at'];

      bool isAvailable = await checkParkingAvailability(startAt);

      if (isAvailable) {
        DocumentReference reservationRef =
            await _firestore.collection('reservations').add({
          'email': _currentUserEmail,
          'address': address,
          'duration': selectedParking['duration'],
          'start_at': startAt,
          'price': selectedParking['price'],
          'description': selectedParking['description'],
        });

        setState(() {
          _selectedReservationRef = reservationRef;
        });

        // Sla de reserveringsgegevens op in de lokale opslag
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('selectedParkingIndex', _selectedParkingIndex);
        prefs.setString('selectedReservationId', reservationRef.id);

        _showSuccessMessage('Parkeerplaats gereserveerd');
      } else {
        _showErrorMessage('Er bestaat al een reservering voor deze starttijd');
      }
    } else {
      _showErrorMessage('Geen parkeerplaats geselecteerd');
    }
  }

  void _cancelReservation() async {
    if (_selectedReservationRef != null) {
      await _selectedReservationRef!.delete();
      _selectedReservationRef = null;

      // Verwijder de opgeslagen reserveringsgegevens uit de lokale opslag
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('selectedParkingIndex');
      prefs.remove('selectedReservationId');

      setState(() {
        _selectedParkingIndex = -1;
      });

      _showSuccessMessage('Reservering geannuleerd');
    } else {
      _showErrorMessage('Geen reservering om te annuleren');
    }
  }

  void _showSuccessMessage(String message) {
    setState(() {
      _successMessageVisible = true;
      _errorMessageVisible = false;
      _message = message;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _successMessageVisible = false;
      });
    });
  }

  void _showErrorMessage(String message) {
    setState(() {
      _successMessageVisible = false;
      _errorMessageVisible = true;
      _message = message;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _errorMessageVisible = false;
      });
    });
  }

  Widget _buildMessageWidget() {
    if (_successMessageVisible) {
      return Container(
        color: Colors.green,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 16.0),
        child: Text(
          _message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (_errorMessageVisible) {
      return Container(
        color: Colors.red,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 16.0),
        child: Text(
          _message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Future<bool> checkDuplicateReservation(String startAt) async {
    QuerySnapshot snapshot = await _firestore
        .collection('reservations')
        .where('start_at', isEqualTo: startAt)
        .get();

    return snapshot.docs.isEmpty;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  Widget _buildCardNumberField() {
    if (_selectedPaymentMethod.isEmpty || _selectedPaymentMethod == 'PayPal') {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kaartnummer:',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Voer de kaartnummer in',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          children: [
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
                    'Profile',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                fetchReservations();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text(_showParkingSlots
                  ? 'Sluit parkeerplaatsen'
                  : 'Toon parkeerplaatsen'),
            ),
            SizedBox(height: 20.0),
            _buildMessageWidget(),
            _showData &&
                    _showParkingSlots // Only show parking slots if _showParkingSlots is true
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot reservation = _reservations[index];
                      double latitude = reservation['latitude'];
                      double longitude = reservation['longitude'];
                      String duration = reservation['duration'].toString();
                      String startAt = reservation['start_at'];
                      String price = reservation['price'];
                      String description = reservation['description'];

                      return FutureBuilder(
                        future: getAddressFromCoordinates(latitude, longitude),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            String address = snapshot.data as String;
                            return ListTile(
                              title: Text(
                                'Parkeerplaats ${index + 1}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Address: $address',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Duration: $duration',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Start At: $startAt',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Price: $price',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'Description: $description',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              trailing: _selectedParkingIndex == index
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green)
                                  : ElevatedButton(
                                      onPressed: () {
                                        chooseParkingSlot(index);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.green,
                                      ),
                                      child: Text('Kies'),
                                    ),
                            );
                          } else {
                            return ListTile(
                              title: Text('Parkeerplaats ${index + 1}'),
                              subtitle: Text('Loading address...'),
                            );
                          }
                        },
                      );
                    },
                  )
                : Container(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _cancelReservation();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: const Text('Reservering annuleren'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                reserveParking();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: const Text('Reserveren'),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Selecteer de betaalmethode:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = _paymentMethods[index];
                return RadioListTile(
                  title: Text(
                    paymentMethod,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  value: paymentMethod,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value as String;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildCardNumberField(),
            const Text(
              'Voer het te betalen bedrag in:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Voer het bedrag in',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final amountToPay =
                    double.tryParse(_amountController.text) ?? 0.0;
                final cardNumber = _cardNumberController.text;
                // hier moet ik de betalingsverwerkingslogica uitvoeren
                print('Geselecteerde betaalmethode: $_selectedPaymentMethod');
                print('Kaartnummer: $cardNumber');
                print('Te betalen bedrag: $amountToPay');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
              child: Text('Nu betalen'),
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
