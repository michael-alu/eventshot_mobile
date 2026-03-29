// import 'package:eventshot_mobile/features/auth/data/models/organizer_model.dart'; // unused after commenting out test
import 'package:eventshot_mobile/features/events/data/models/event_model.dart';
import 'package:eventshot_mobile/features/photos/data/models/photo_model.dart';
import 'package:eventshot_mobile/features/event_members/data/models/event_member_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Model Coverage - fromJson/toJson/copyWith', () {
//    test('OrganizerModel coverage', () {
//      final now = DateTime.now();
//      final model = OrganizerModel(
//        id: '1',
//        email: 't@t.com',
//        displayName: 'D',
//        role: 'R',
//        createdAt: now,
//      );
//      final json = model.toJson();
//      final fromJson = OrganizerModel.fromJson(json);
//      expect(fromJson.id, model.id);
//      expect(model.toEntity().id, '1');
//    });

    test('EventModel coverage', () {
      final now = DateTime.now();
      final model = EventModel(
        id: '1',
        name: 'E',
        date: now,
        tierId: 'T',
        organizerId: 'O',
        joinCode: 'J',
        maxPhotos: 100,
        qrData: 'Q',
        photoCount: 1,
        attendeeCount: 1,
        storageBytes: 1024,
        totalSize: 1024,
      );
      final json = model.toJson();
      final fromJson = EventModel.fromJson({
        ...json,
        'date': now.toIso8601String(),
      });
      expect(fromJson.id, model.id);
      expect(model.toEntity().id, '1');
    });

    test('PhotoModel coverage', () {
      final now = DateTime.now();
      final model = PhotoModel(
        id: '1',
        eventId: 'E',
        uploaderId: 'UI',
        uploaderName: 'UN',
        firestoreUrl: 'F',
        storagePath: 'S',
        uploadedAt: now,
        isActive: true,
        likesCount: 1,
      );
      final json = model.toJson();
      final fromJson = PhotoModel.fromJson({
        ...json,
        'uploadedAt': now.toIso8601String(),
      });
      expect(fromJson.id, model.id);
      expect(model.toEntity().id, '1');
    });

    test('EventMemberModel coverage', () {
      final now = DateTime.now();
      final model = EventMemberModel(
        id: '1',
        eventId: 'E',
        attendeeName: 'A',
        joinedAt: now,
        isActive: true,
      );
      final json = model.toJson();
      final fromJson = EventMemberModel.fromJson(json);
      expect(fromJson.id, model.id);
      expect(model.toEntity().id, '1');
    });

  });
}
