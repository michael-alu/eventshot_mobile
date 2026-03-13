import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event_member.dart';
import '../../domain/repositories/event_member_repository.dart';
import '../models/event_member_model.dart';
import '../../../events/data/models/event_model.dart';

class EventMemberRepositoryImpl implements EventMemberRepository {
  EventMemberRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collection = 'event_members';

  @override
  Future<EventMember> joinEventWithCode({
    required String joinCode,
    required String attendeeName,
  }) async {
    // 1. Find the event with this join code
    final eventQuery = await _firestore
        .collection('events')
        .where('joinCode', isEqualTo: joinCode.toUpperCase())
        .limit(1)
        .get();

    if (eventQuery.docs.isEmpty) {
      throw Exception('Invalid join code');
    }

    final eventDoc = eventQuery.docs.first;
    final eventModel =
        EventModel.fromJson({...eventDoc.data(), 'id': eventDoc.id});

    // 2. Create the member record
    final ref = _firestore.collection(_collection).doc();
    final model = EventMemberModel(
      id: ref.id,
      eventId: eventModel.id,
      attendeeName: attendeeName,
      joinedAt: DateTime.now(),
    );

    await ref.set(model.toJson());

    // 3. Increment the event's attendee count
    await eventDoc.reference.update({
      'attendeeCount': FieldValue.increment(1),
    });

    return model.toEntity();
  }

  @override
  Stream<List<EventMember>> watchEventMembers(String eventId) {
    return _firestore
        .collection(_collection)
        .where('eventId', isEqualTo: eventId)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventMemberModel.fromJson({...doc.data(), 'id': doc.id}).toEntity();
      }).toList();
    });
  }

  @override
  Future<void> leaveEvent(String memberId) async {
    await _firestore.collection(_collection).doc(memberId).update({
      'isActive': false,
    });
    // Ideally decrement event attendeeCount via Cloud Function
  }
}
