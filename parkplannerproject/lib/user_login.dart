import 'package:flutter/material.dart';

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({Key? key}) : super(key: key);

  @override //later in andere branch maken
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Login'),
      ),
      body: const Center(
        child: Text('Welcome to the User Login Page!'),
      ),
    );
  }
}
