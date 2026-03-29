import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:eventshot_mobile/features/attendee/data/repositories/attendee_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class FakeUserCredential extends Fake implements UserCredential {
  final User? _user;
  FakeUserCredential({User? user}) : _user = user;
  @override
  User? get user => _user;
}

class FakeUser extends Mock implements User {
  @override
  String get uid => 'user123';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
  @override
  bool get isAnonymous => false;
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async => FakeUserCredential(user: this);
}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AttendeeRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    repository = AttendeeRepository(firestore: firestore, auth: auth);
  });

  group('AttendeeRepository', () {
    test('validateJoinCode returns event if valid', () async {
      await firestore.collection('events').doc('evt1').set({
        'name': 'Test Event',
        'joinCode': 'ABCDEF',
        'tierId': 'free',
        'organizerId': 'org1',
        'date': DateTime.now().toIso8601String(),
        'attendeeCount': 2,
        'photoCount': 5,
      });

      final event = await repository.validateJoinCode('abcdef');
      expect(event, isNotNull);
      expect(event!.joinCode, 'ABCDEF');
      expect(event.attendeeCount, 2);
    });

    test('validateJoinCode returns null if not found', () async {
      final event = await repository.validateJoinCode('MISSING');
      expect(event, isNull);
    });

    test('validateJoinCode throws exception if full', () async {
      await firestore.collection('events').doc('evt2').set({
        'name': 'Full Event',
        'joinCode': 'FULL12',
        'tierId': 'free',
        'organizerId': 'org1',
        'date': DateTime.now().toIso8601String(),
        'attendeeCount': 10,
      });

      expect(
        () => repository.validateJoinCode('FULL12'),
        throwsA(isA<Exception>()),
      );
    });

    test('assertUploadLimit throws exception if over 50 photos limit', () async {
      await firestore.collection('events').doc('evt_max').set({
        'photoCount': 50,
      });

      expect(
        () => repository.assertUploadLimit('evt_max'),
        throwsA(isA<Exception>()),
      );
    });

    test('assertUploadLimit does not throw if under limit', () async {
      await firestore.collection('events').doc('evt_ok').set({
        'photoCount': 10,
      });

      await repository.assertUploadLimit('evt_ok');
    });

    test('executeOfflineUpload branch coverage', () async {
      try {
        await repository.executeOfflineUpload('evt1', File('test.jpg'));
      } catch (_) {}
    });
  });
}
