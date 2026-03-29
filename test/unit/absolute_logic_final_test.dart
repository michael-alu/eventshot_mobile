import 'package:eventshot_mobile/features/attendee/data/repositories/attendee_repository.dart';
import 'package:eventshot_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:eventshot_mobile/features/event_members/data/repositories/event_member_repository_impl.dart';
import 'package:eventshot_mobile/core/services/cloudinary_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('Absolute Logic Final Booster - THE 70% HIT', () {
    final firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();

    test('AttendeeRepository Logic Coverage', () async {
      final repo = AttendeeRepository(firestore: firestore, auth: auth);
      
      // Seed an event
      await firestore.collection('events').doc('e1').set({
        'id': 'e1',
        'name': 'Logic Event',
        'date': DateTime.now().toIso8601String(),
        'tierId': 'free',
        'joinCode': 'LOGIC1',
        'attendeeCount': 0,
      });

      final event = await repo.validateJoinCode('logic1');
      expect(event?.name, 'Logic Event');

      await repo.assertUploadLimit('e1');
      
      // Full event test
      await firestore.collection('events').doc('e1').update({'attendeeCount': 10});
      expect(() => repo.validateJoinCode('logic1'), throwsException);
    });

    test('EventRepositoryImpl Logic Coverage', () async {
      final repo = EventRepositoryImpl(firestore: firestore);
      await repo.createEvent(name: 'N', date: DateTime.now(), tierId: 'pro', organizerId: 'o1');
      final events = await repo.getOrganizerEvents('o1').first;
      expect(events, isNotEmpty);
    });

    test('CloudinaryService Stats Coverage', () {
      const stats = CloudinaryFolderStats(totalBytes: 2097152, totalCount: 10);
      expect(stats.totalMb, 2.0);
      expect(stats.toString(), contains('10'));
    });

    test('EventMemberRepositoryImpl Logic Coverage', () async {
      final repo = EventMemberRepositoryImpl(firestore: firestore);
      await firestore.collection('event_members').add({
        'eventId': 'e1',
        'isActive': true,
        'attendeeName': 'Tester',
        'joinedAt': DateTime.now().toIso8601String(),
      });
      final members = await repo.watchEventMembers('e1').first;
      expect(members, isNotEmpty);
    });
  });
}
