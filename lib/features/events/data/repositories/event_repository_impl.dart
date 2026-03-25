import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../models/event_model.dart';
import '../../../../core/services/cloudinary_service.dart';

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
    // Generate a new document reference so we can get its ID
    final ref = _firestore.collection(_collection).doc();
    
    // Set default photo limits based on the selected pricing tier
    int maxPhotos = 50;
    if (tierId == 'pro') maxPhotos = 1000;
    if (tierId == 'enterprise') maxPhotos = -1; // -1 means unlimited photos

    final model = EventModel(
      id: ref.id,
      name: name,
      date: date,
      tierId: tierId,
      organizerId: organizerId,
      joinCode: EventModel.generateJoinCode(),
      maxPhotos: maxPhotos,
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

  @override
  Future<void> updateEvent(Event event) async {
    // Convert the Event entity back to a model so we can save it to Firestore
    final model = EventModel(
      id: event.id,
      name: event.name,
      date: event.date,
      tierId: event.tierId,
      organizerId: event.organizerId,
      joinCode: event.joinCode,
      maxPhotos: event.maxPhotos,
      qrData: event.qrData,
      photoCount: event.photoCount,
      attendeeCount: event.attendeeCount,
      storageBytes: event.storageBytes,
    );
    await _firestore.collection(_collection).doc(event.id).update(model.toJson());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    // Step 1: Wipe all associated images from Cloudinary storage first
    await CloudinaryService.deleteEventFolder(eventId: eventId);
    
    // Step 2: Delete every document in the attendees subcollection
    final attendees = await _firestore.collection(_collection).doc(eventId).collection('attendees').get();
    for (final doc in attendees.docs) {
      await doc.reference.delete();
    }
    
    // Step 3: Delete every document in the photos subcollection
    final photos = await _firestore.collection(_collection).doc(eventId).collection('photos').get();
    for (final doc in photos.docs) {
      await doc.reference.delete();
    }
    
    // Step 4: Delete the main event document itself
    await _firestore.collection(_collection).doc(eventId).delete();
  }

  @override
  Stream<List<Event>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection(_collection)
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventModel.fromJson({...doc.data(), 'id': doc.id}).toEntity();
      }).toList();
    });
  }
}
