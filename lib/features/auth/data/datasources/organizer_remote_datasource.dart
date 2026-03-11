import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/organizer_model.dart';

/// Firestore access for organizer profile documents.
class OrganizerRemoteDataSource {
  OrganizerRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _collection = 'organizers';

  Future<void> setOrganizer(OrganizerModel model) async {
    await _firestore.collection(_collection).doc(model.id).set(model.toJson());
  }

  Future<OrganizerModel?> getOrganizer(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return OrganizerModel.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }
}
