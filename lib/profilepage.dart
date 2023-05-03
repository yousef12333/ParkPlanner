import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _ProfilePage extends StatelessWidget {
  final String voornaam;
  final String achternaam;
  final List<String> merkVoertuigen;
  final String contactgegevens;
  final String thuisadres;
  final List<String> recenteParkeerreserveringen;
  final List<String> gedaneBetalingen;

  _ProfilePage({
    required this.voornaam,
    required this.achternaam,
    required this.merkVoertuigen,
    required this.contactgegevens,
    required this.thuisadres,
    required this.recenteParkeerreserveringen,
    required this.gedaneBetalingen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profiel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voornaam: $voornaam',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Achternaam: $achternaam',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Merk voertuigen:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              merkVoertuigen.join(', '),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Contactgegevens: $contactgegevens',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Thuisadres: $thuisadres',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Recente parkeerreserveringen:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recenteParkeerreserveringen
                  .map(
                    (reservation) => Text(
                      reservation,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Gedane betalingen:',
              style: TextStyle(fontSize: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: gedaneBetalingen
                  .map(
                    (payment) => Text(
                      payment,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
