// ████████████████████████████████████████████████████████████████
//  AUTO-GENERATED — DO NOT EDIT MANUALLY
//
//  Run this command to generate this file automatically:
//
//    flutterfire configure
//
//  Steps:
//  1. Install FlutterFire CLI:
//        dart pub global activate flutterfire_cli
//
//  2. Log in to Firebase:
//        firebase login
//
//  3. Run in your project folder:
//        flutterfire configure
//
//  4. Select your Firebase project: immune-diet-ai
//  5. Select Android (and iOS if needed)
//  6. This file will be auto-generated with your real credentials!
//
//  The google-services.json will also be placed automatically in:
//        android/app/google-services.json
// ████████████████████████████████████████████████████████████████

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default: throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.');
    }
  }

  // ── REPLACE these values after running: flutterfire configure ──────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'YOUR_API_KEY',
    appId:             'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId:         'YOUR_PROJECT_ID',
    authDomain:        'YOUR_PROJECT.firebaseapp.com',
    storageBucket:     'YOUR_PROJECT.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_ANDROID_API_KEY',
    appId:             'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'YOUR_IOS_API_KEY',
    appId:             'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT.appspot.com',
    iosBundleId:       'com.immunedietai.app',
  );
}
