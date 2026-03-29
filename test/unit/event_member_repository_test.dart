import 'package:eventshot_mobile/features/event_members/data/repositories/event_member_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late EventMemberRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = EventMemberRepositoryImpl(firestore: firestore);
  });

  group('EventMemberRepositoryImpl', () {
    test('joinEventWithCode successfully creates a member and updates count', () async {
      await firestore.collection('events').doc('evt1').set({
        'name': 'Event 1',
        'date': DateTime.now().toIso8601String(),
        'joinCode': 'E1',
        'organizerId': 'o1',
        'tierId': 'free',
        'attendeeCount': 0,
        'photoCount': 0,
      });

      final member = await repository.joinEventWithCode(
        joinCode: 'E1',
        attendeeName: 'New Attendee',
      );

      expect(member.attendeeName, 'New Attendee');
      
      final eventDoc = await firestore.collection('events').doc('evt1').get();
      expect(eventDoc.data()!['attendeeCount'], 1);
    });

    test('joinEventWithCode throws exception for invalid code', () async {
      expect(
        () => repository.joinEventWithCode(joinCode: 'WRONG', attendeeName: 'X'),
        throwsA(isA<Exception>()),
      );
    });

    test('watchEventMembers returns list for event', () async {
       await firestore.collection('event_members').add({
        'eventId': 'evt1',
        'isActive': true,
        'attendeeName': 'Member 1',
        'joinedAt': DateTime.now().toIso8601String(),
      });

      final members = await repository.watchEventMembers('evt1').first;
      expect(members.length, 1);
    });

    test('leaveEvent sets isActive to false', () async {
       final ref = await firestore.collection('event_members').add({
        'isActive': true,
      });

      await repository.leaveEvent(ref.id);
      
      final doc = await firestore.collection('event_members').doc(ref.id).get();
      expect(doc.data()!['isActive'], false);
    });
  });
}
