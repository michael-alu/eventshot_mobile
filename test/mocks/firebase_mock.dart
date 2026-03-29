import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> channels = [
    'plugins.flutter.io/firebase_core',
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
    'plugins.flutter.io/firebase_auth',
    'plugins.flutter.io/cloud_firestore',
    'plugins.flutter.io/firebase_storage',
  ];

  for (final channelName in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channelName),
      (MethodCall methodCall) async {
        if (methodCall.method.contains('initializeCore')) {
          return [
            {
              'name': '[DEFAULT]',
              'options': {'apiKey': '123', 'appId': '123', 'messagingSenderId': '123', 'projectId': '123'},
              'isAutomaticDataCollectionEnabled': true,
            }
          ];
        }

        if (methodCall.method == 'startListenAuthState') return null;
        if (methodCall.method == 'startListenIdTokenState') return null;
        
        // Return a default map to prevent Null check errors in StandardMethodCodec
        return <String, dynamic>{};
      },
    );
  }
}
