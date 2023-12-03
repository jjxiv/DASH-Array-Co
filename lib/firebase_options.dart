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
    apiKey: 'AIzaSyCub-MSLfAaamtorEHlubeG3VJVe0QUZ8A',
    appId: '1:968648410379:web:c9e68d28253658ea214e0e',
    messagingSenderId: '968648410379',
    projectId: 'dash-login-779b0',
    authDomain: 'dash-login-779b0.firebaseapp.com',
    storageBucket: 'dash-login-779b0.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBshaX15F3xng9p3deUAyjGWQGZd12OhYI',
    appId: '1:968648410379:android:673e1b1266ac3f98214e0e',
    messagingSenderId: '968648410379',
    projectId: 'dash-login-779b0',
    storageBucket: 'dash-login-779b0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCByKUqi-TM4omL5QWxfQtJ0z2fj_IzdYo',
    appId: '1:968648410379:ios:50b097726a015e60214e0e',
    messagingSenderId: '968648410379',
    projectId: 'dash-login-779b0',
    storageBucket: 'dash-login-779b0.appspot.com',
    iosClientId: '968648410379-1hqlf2rraum4ipqp8lbfgvkpmta7b1gq.apps.googleusercontent.com',
    iosBundleId: 'com.example.dash',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCByKUqi-TM4omL5QWxfQtJ0z2fj_IzdYo',
    appId: '1:968648410379:ios:50b097726a015e60214e0e',
    messagingSenderId: '968648410379',
    projectId: 'dash-login-779b0',
    storageBucket: 'dash-login-779b0.appspot.com',
    iosClientId: '968648410379-1hqlf2rraum4ipqp8lbfgvkpmta7b1gq.apps.googleusercontent.com',
    iosBundleId: 'com.example.dash',
  );
}
