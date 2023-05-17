import 'package:flutter/material.dart';
import 'package:parkplannerproject/user_registration.dart';

import 'edit_password.dart';

/*String firstName = RegistrationPageState().firstName;
String lastName = RegistrationPageState().firstName;
int phoneNumber = RegistrationPageState().phoneNumber as int;*/
String firstName = "Jhon";
String lastName = "Jo";
String vehicleBrands = 'Mercedes';
int phoneNumber = 0032465207104;
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
            leading: Icon(Icons.directions_car, color: Colors.green),
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
                    icon: Icon(Icons.save, color: Colors.green),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit, color: Colors.green),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.phone, color: Colors.green),
            title: Text('Telefoonnummer'),
            subtitle: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: phoneNumber.toString(),
                    enabled: isEditing,
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = int.parse(value);
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
                    icon: Icon(Icons.save, color: Colors.green),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit, color: Colors.green),
                  ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.home, color: Colors.green),
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
                    icon: Icon(Icons.save, color: Colors.green),
                  ),
                if (!isEditing)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    icon: Icon(Icons.edit, color: Colors.green),
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Bewerk Wachtwoord',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text('Wachtwoord wijzigen'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.green,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditPasswordPage()),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help en Ondersteuning',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Contact opnemen met klantenservice:',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.green, // Voeg een gewenste kleur toe
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '046522071',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.green, // Voeg een gewenste kleur toe
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'parkplanner@klantenservice.be',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      //Navigation
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
