// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7f1eO338mgPi62KnPKxEvwVeSacImr58',
    appId: '1:1096347164865:web:3576c3be1f1968abb6b440',
    messagingSenderId: '1096347164865',
    projectId: 'parkplanner2',
    authDomain: 'parkplanner2.firebaseapp.com',
    storageBucket: 'parkplanner2.appspot.com',
    measurementId: 'G-YC4R1N7GP9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA9-TbmVAzXRkHtHG8lCyylLVBuc8_yGhI',
    appId: '1:1096347164865:android:b9bfb965ce9dd5a1b6b440',
    messagingSenderId: '1096347164865',
    projectId: 'parkplanner2',
    storageBucket: 'parkplanner2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCH3_7ByeKTAjvqW-BLXW-TVixkocT67gU',
    appId: '1:1096347164865:ios:0ad2c4fda1f01cbbb6b440',
    messagingSenderId: '1096347164865',
    projectId: 'parkplanner2',
    storageBucket: 'parkplanner2.appspot.com',
    iosClientId:
        '1096347164865-il78b7ka9l2pb7l8f53bh5su8qg0liiu.apps.googleusercontent.com',
    iosBundleId: 'com.example.parkplannerproject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCH3_7ByeKTAjvqW-BLXW-TVixkocT67gU',
    appId: '1:1096347164865:ios:0ad2c4fda1f01cbbb6b440',
    messagingSenderId: '1096347164865',
    projectId: 'parkplanner2',
    storageBucket: 'parkplanner2.appspot.com',
    iosClientId:
        '1096347164865-il78b7ka9l2pb7l8f53bh5su8qg0liiu.apps.googleusercontent.com',
    iosBundleId: 'com.example.parkplannerproject',
  );
}
