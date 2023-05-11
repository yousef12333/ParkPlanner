import 'package:flutter/material.dart';

String firstName = 'Sam';
String lastName = 'John';
String vehicleBrands = 'Mercedes';
String email = 'samjohn52h@hotmail.com';
String homeAddress = 'Ruggenveldlaan, 799, 2100, Deurne';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabledNot = true;
  bool _notificationsEnabledWar = true;
  bool isEditing = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        // ignore: sort_child_properties_last
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voornaam: $firstName',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Achternaam: $lastName',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text('Vehicle Brands'),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: vehicleBrands,
                    enabled: isEditing,
                    onChanged: (value) {
                      setState(() {
                        vehicleBrands = value;
                      });
                    },
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    icon: Icon(Icons.save),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('Email'),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: email,
                    enabled: isEditing,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    icon: Icon(Icons.save),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Address'),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: homeAddress,
                    enabled: isEditing,
                    onChanged: (value) {
                      setState(() {
                        homeAddress = value;
                      });
                    },
                  ),
                ),
                if (isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                      });
                    },
                    icon: Icon(Icons.save),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Preferences and Settings',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: Text('Notifications'),
            value: _notificationsEnabledNot,
            onChanged: (value) {
              setState(() {
                _notificationsEnabledNot = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Warnings'),
            value: _notificationsEnabledWar,
            onChanged: (value) {
              setState(() {
                _notificationsEnabledWar = value;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Activity Overview',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            title: Text('Recent Parking Reservations'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[19-03-23, 12:00u, Parking Abdijstraat]'),
                Text('[05-03-23, 8:00u, Parking Zuid Rivierenhof]'),
                Text('[27-02-23, 21:15u, Parking Meir]'),
              ],
            ),
          ),
          const ListTile(
            title: Text('Payments Made'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[11-03-23, €12, Creditcard]'),
                Text('[05-03-23, €4, Creditcard]'),
                Text('[27-02-23, €16, PayPal]'),
              ],
            ),
          ),
        ],
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
