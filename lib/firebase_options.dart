// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyClM4Zd5GG06JORVF-8oN7ZVBe8yDPiKGY',
    appId: '1:719571627580:web:54950841a1a4229443dd39',
    messagingSenderId: '719571627580',
    projectId: 'scooter-control-form',
    authDomain: 'scooter-control-form.firebaseapp.com',
    storageBucket: 'scooter-control-form.appspot.com',
    measurementId: 'G-P9ESZJBS7L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSxfxvPE7U2GOeSBzMXLKL5BG-rQwHc-k',
    appId: '1:719571627580:android:52690c8e6e9bce6d43dd39',
    messagingSenderId: '719571627580',
    projectId: 'scooter-control-form',
    storageBucket: 'scooter-control-form.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTOAzEKSuos0YAjUom8fA1knm9Ha5NVIc',
    appId: '1:719571627580:ios:4e6c6b08641618eb43dd39',
    messagingSenderId: '719571627580',
    projectId: 'scooter-control-form',
    storageBucket: 'scooter-control-form.appspot.com',
    iosBundleId: 'com.example.scooterForm',
  );
}
