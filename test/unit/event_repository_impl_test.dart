import 'package:eventshot_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late EventRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = EventRepositoryImpl(firestore: firestore);
  });

  group('EventRepositoryImpl', () {
    test('createEvent successfully creates a document', () async {
      final date = DateTime.now();
      final event = await repository.createEvent(
        name: 'Test Event',
        date: date,
        tierId: 'pro',
        organizerId: 'org123',
      );

      expect(event.name, 'Test Event');
      expect(event.tierId, 'pro');
      expect(event.maxPhotos, 1000); // Pro tier limit
      
      final doc = await firestore.collection('events').doc(event.id).get();
      expect(doc.exists, true);
      expect(doc.data()!['name'], 'Test Event');
    });

    test('watchEvent returns stream of event', () async {
      await firestore.collection('events').doc('evt1').set({
        'name': 'Live Event',
        'tierId': 'free',
        'joinCode': '123456',
        'organizerId': 'org1',
        'date': DateTime.now().toIso8601String(),
      });

      final stream = repository.watchEvent('evt1');
      final event = await stream.first;
      
      expect(event, isNotNull);
      expect(event!.name, 'Live Event');
    });

    test('getEvent returns correct event', () async {
      await firestore.collection('events').doc('evt2').set({
        'name': 'Stored Event',
        'tierId': 'free',
        'joinCode': 'ABCDEF',
        'organizerId': 'org1',
        'date': DateTime.now().toIso8601String(),
      });

      final event = await repository.getEvent('evt2');
      expect(event?.name, 'Stored Event');
    });

    test('updateEvent updates existing document', () async {
       await firestore.collection('events').doc('evt3').set({
        'name': 'Old Name',
        'tierId': 'free',
        'joinCode': '111222',
        'organizerId': 'org1',
        'date': DateTime.now().toIso8601String(),
      });

      final event = Event(
        id: 'evt3',
        name: 'New Name',
        date: DateTime.now(),
        tierId: 'free',
        organizerId: 'org1',
        joinCode: '111222',
        maxPhotos: 50,
      );

      await repository.updateEvent(event);
      
      final doc = await firestore.collection('events').doc('evt3').get();
      expect(doc.data()!['name'], 'New Name');
    });

    test('getOrganizerEvents returns filtered list', () async {
       await firestore.collection('events').add({
        'name': 'Event 1',
        'organizerId': 'me',
        'date': DateTime.now().toIso8601String(),
        'joinCode': 'E1',
        'tierId': 'free',
      });
      await firestore.collection('events').add({
        'name': 'Event 2',
        'organizerId': 'other',
        'date': DateTime.now().toIso8601String(),
        'joinCode': 'E2',
        'tierId': 'free',
      });

      final events = await repository.getOrganizerEvents('me').first;
      expect(events.length, 1);
      expect(events.first.name, 'Event 1');
    });
  });
}
