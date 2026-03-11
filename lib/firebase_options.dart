// Stub: run `flutterfire configure` to generate real options for your Firebase project.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:0:android:0',
    messagingSenderId: '0',
    projectId: 'eventshot-placeholder',
    storageBucket: 'eventshot-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:0:ios:0',
    messagingSenderId: '0',
    projectId: 'eventshot-placeholder',
    storageBucket: 'eventshot-placeholder.appspot.com',
    iosBundleId: 'com.example.eventshotMobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'PLACEHOLDER',
    appId: '1:0:macos:0',
    messagingSenderId: '0',
    projectId: 'eventshot-placeholder',
    storageBucket: 'eventshot-placeholder.appspot.com',
    iosBundleId: 'com.example.eventshotMobile',
  );
}
