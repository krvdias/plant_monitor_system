// **************************************************************************
// IMPORTANT: This is a PLACEHOLDER file.
//
// You MUST replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// That command will auto-generate the real version of this file using
// your Firebase project credentials.
//
// Steps:
//   1. Open a terminal in this project folder
//   2. Run: dart pub global activate flutterfire_cli
//   3. Run: flutterfire configure
//   4. Select your Firebase project from the list
//   5. This file will be automatically overwritten with correct values
// **************************************************************************

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── REPLACE ALL VALUES BELOW WITH YOUR REAL FIREBASE CONFIG ──────────────
  // These dummy values will cause a runtime error. Run `flutterfire configure`
  // to generate the correct values automatically.

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    databaseURL: 'https://REPLACE_ME.firebaseio.com',
    storageBucket: 'REPLACE_ME.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXrIKZFpPov5XCQ1ONltQJgbAweip9Sw8',
    appId: '1:1073555670171:android:bef7a2ab423ffef4c3723e',
    messagingSenderId: '1073555670171',
    projectId: 'plant-monitor-system',
    databaseURL: 'https://plant-monitor-system-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'plant-monitor-system.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    databaseURL: 'https://REPLACE_ME.firebaseio.com',
    storageBucket: 'REPLACE_ME.appspot.com',
    iosBundleId: 'com.smartplant.smartPlantMonitor',
  );
}
