import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/features/events/domain/entities/event.dart';

void main() {
  final testDate = DateTime(2024, 6, 15);

  Event makeEvent({
    String id = 'evt-1',
    String name = 'Test Event',
    String tierId = 'free',
    String? organizerId,
    String joinCode = 'ABC123',
    int maxPhotos = 50,
    String qrData = '',
    int photoCount = 0,
    int attendeeCount = 0,
    int storageBytes = 0,
    int totalSize = 0,
  }) =>
      Event(
        id: id,
        name: name,
        date: testDate,
        tierId: tierId,
        organizerId: organizerId,
        joinCode: joinCode,
        maxPhotos: maxPhotos,
        qrData: qrData,
        photoCount: photoCount,
        attendeeCount: attendeeCount,
        storageBytes: storageBytes,
        totalSize: totalSize,
      );

  group('Event entity defaults', () {
    test('joinCode defaults to empty string', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.joinCode, '');
    });

    test('maxPhotos defaults to -1', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.maxPhotos, -1);
    });

    test('photoCount defaults to 0', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.photoCount, 0);
    });

    test('attendeeCount defaults to 0', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.attendeeCount, 0);
    });

    test('organizerId defaults to null', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.organizerId, isNull);
    });

    test('storageBytes defaults to 0', () {
      final e = Event(id: 'x', name: 'N', date: testDate, tierId: 'free');
      expect(e.storageBytes, 0);
    });
  });

  group('Event Equatable equality', () {
    test('two events with same fields are equal', () {
      final a = makeEvent();
      final b = makeEvent();
      expect(a, equals(b));
    });

    test('events with different ids are not equal', () {
      final a = makeEvent(id: 'evt-1');
      final b = makeEvent(id: 'evt-2');
      expect(a, isNot(equals(b)));
    });

    test('events with different names are not equal', () {
      final a = makeEvent(name: 'Party');
      final b = makeEvent(name: 'Wedding');
      expect(a, isNot(equals(b)));
    });

    test('events with different joinCodes are not equal', () {
      final a = makeEvent(joinCode: 'AAA111');
      final b = makeEvent(joinCode: 'BBB222');
      expect(a, isNot(equals(b)));
    });

    test('events with different photoCounts are not equal', () {
      final a = makeEvent(photoCount: 10);
      final b = makeEvent(photoCount: 20);
      expect(a, isNot(equals(b)));
    });
  });

  group('Event props list', () {
    test('props list has 12 elements', () {
      final e = makeEvent();
      expect(e.props.length, 12);
    });

    test('props list includes id, name, date, tierId', () {
      final e = makeEvent(id: 'evt-99', name: 'My Event', tierId: 'pro');
      expect(e.props, containsAll(['evt-99', 'My Event', testDate, 'pro']));
    });

    test('props list includes joinCode', () {
      final e = makeEvent(joinCode: 'XYZ789');
      expect(e.props, contains('XYZ789'));
    });
  });
}
