import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/features/events/data/models/event_model.dart';
import 'package:eventshot_mobile/features/events/domain/entities/event.dart';

void main() {
  final testDate = DateTime(2024, 8, 10, 18, 30);

  final sampleJson = {
    'id': 'evt-001',
    'name': 'Summer Gala 2024',
    'date': testDate.toIso8601String(),
    'tierId': 'pro',
    'organizerId': 'org-abc',
    'joinCode': 'AB1234',
    'maxPhotos': 200,
    'qrData': 'https://eventshot.app/join/AB1234',
    'photoCount': 42,
    'attendeeCount': 15,
    'storageBytes': 104857600,
  };

  group('EventModel serialization', () {
    test('fromJson populates all fields correctly', () {
      final model = EventModel.fromJson(sampleJson);

      expect(model.id, 'evt-001');
      expect(model.name, 'Summer Gala 2024');
      expect(model.date, testDate);
      expect(model.tierId, 'pro');
      expect(model.organizerId, 'org-abc');
      expect(model.joinCode, 'AB1234');
      expect(model.maxPhotos, 200);
      expect(model.qrData, 'https://eventshot.app/join/AB1234');
      expect(model.photoCount, 42);
      expect(model.attendeeCount, 15);
      expect(model.storageBytes, 104857600);
    });

    test('toJson round-trips correctly', () {
      final model = EventModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], sampleJson['id']);
      expect(json['name'], sampleJson['name']);
      expect(json['tierId'], sampleJson['tierId']);
      expect(json['joinCode'], sampleJson['joinCode']);
      expect(json['maxPhotos'], sampleJson['maxPhotos']);
      expect(json['photoCount'], sampleJson['photoCount']);
    });

    test('toEntity maps to Event domain object', () {
      final model = EventModel.fromJson(sampleJson);
      final entity = model.toEntity();

      expect(entity, isA<Event>());
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.joinCode, model.joinCode);
      expect(entity.tierId, model.tierId);
    });

    test('fromJson uses defaults when optional fields are absent', () {
      final minimal = {
        'id': 'evt-min',
        'name': 'Minimal Event',
        'date': testDate.toIso8601String(),
        'tierId': 'free',
      };
      final model = EventModel.fromJson(minimal);

      expect(model.joinCode, '');
      expect(model.maxPhotos, -1);
      expect(model.qrData, '');
      expect(model.photoCount, 0);
      expect(model.attendeeCount, 0);
      expect(model.organizerId, isNull);
    });
  });
}
