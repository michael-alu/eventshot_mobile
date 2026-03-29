import 'dart:io';

import 'package:eventshot_mobile/core/services/cloudinary_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudinaryService Unit Tests', () {
    test('generateArchiveUrl constructs valid URL', () {
      final url = CloudinaryService.generateArchiveUrl(eventId: 'test_event');

      expect(url, contains('cloudinary.com'));
      expect(url, contains('generate_archive'));
      expect(url, contains('prefixes=eventshot%2Ftest_event%2Fimages%2F'));
      expect(url, contains('api_key=431225626468716'));
    });

    test('generateArchiveUrl includes all required query params', () {
      final url = CloudinaryService.generateArchiveUrl(eventId: 'myevent');
      expect(url, contains('signature='));
      expect(url, contains('timestamp='));
      expect(url, contains('target_format=zip'));
      expect(url, contains('mode=download'));
      expect(url, contains('flatten_folders=true'));
    });

    test('getFolderStats returns stats for an event folder', () async {
      // Covers the full HTTP request path; returns 0 resources for a non-existent event.
      final stats = await CloudinaryService.getFolderStats(eventId: 'nonexistent_test_event_xyz');
      expect(stats.totalCount, isA<int>());
      expect(stats.totalBytes, isA<int>());
    });

    test('deleteEventFolder swallows network errors without throwing', () async {
      // deleteEventFolder catches all errors internally — should complete without throwing.
      await expectLater(
        CloudinaryService.deleteEventFolder(eventId: 'test_event'),
        completes,
      );
    });

    test('uploadImage throws on missing file', () async {
      final fakeFile = File('/nonexistent/path/image.jpg');
      await expectLater(
        () => CloudinaryService.uploadImage(fakeFile, eventId: 'evt1'),
        throwsA(anything),
      );
    });
  });

  group('CloudinaryFolderStats', () {
    test('totalMb converts bytes to megabytes', () {
      const stats = CloudinaryFolderStats(totalBytes: 1048576, totalCount: 5);
      expect(stats.totalMb, closeTo(1.0, 0.001));
    });

    test('totalMb is 0 when no bytes', () {
      const stats = CloudinaryFolderStats(totalBytes: 0, totalCount: 0);
      expect(stats.totalMb, 0.0);
    });

    test('toString includes file count and MB', () {
      const stats = CloudinaryFolderStats(totalBytes: 2097152, totalCount: 10);
      final str = stats.toString();
      expect(str, contains('10'));
      expect(str, contains('2.00'));
    });

    test('constructor stores values correctly', () {
      const stats = CloudinaryFolderStats(totalBytes: 500, totalCount: 3);
      expect(stats.totalBytes, 500);
      expect(stats.totalCount, 3);
    });
  });
}
