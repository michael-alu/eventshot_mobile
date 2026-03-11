import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _collection = 'events';

  @override
  Future<Event> createEvent({
    required String name,
    required DateTime date,
    required String tierId,
    required String organizerId,
  }) async {
    final ref = _firestore.collection(_collection).doc();
    final model = EventModel(
      id: ref.id,
      name: name,
      date: date,
      tierId: tierId,
      organizerId: organizerId,
    );
    await ref.set(model.toJson());
    return model.toEntity();
  }

  @override
  Stream<Event?> watchEvent(String eventId) {
    return _firestore.collection(_collection).doc(eventId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return EventModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
    });
  }

  @override
  Future<Event?> getEvent(String eventId) async {
    final doc = await _firestore.collection(_collection).doc(eventId).get();
    if (!doc.exists || doc.data() == null) return null;
    return EventModel.fromJson({...doc.data()!, 'id': doc.id}).toEntity();
  }
}
