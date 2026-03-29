import 'package:flutter_test/flutter_test.dart';
import 'package:eventshot_mobile/features/auth/data/models/organizer_model.dart';
import 'package:eventshot_mobile/features/auth/domain/entities/organizer.dart';

void main() {
  group('OrganizerModel', () {
    final tModel = OrganizerModel(
      id: 'org123',
      email: 'test@example.com',
      displayName: 'Test User',
      role: 'admin',
      createdAt: DateTime(2023, 1, 1),
    );

    test('should be a subclass of Organizer entity', () {
      expect(tModel.toEntity(), isA<Organizer>());
    });

    test('toJson returns a valid map', () {
      final result = tModel.toJson();
      final expectedMap = {
        'id': 'org123',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'admin',
        'createdAt': '2023-01-01T00:00:00.000',
      };
      
      expect(result, expectedMap);
    });

    test('fromJson returns a valid model from String', () {
      final jsonMap = {
        'id': 'org123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'role': 'admin',
        'createdAt': '2023-01-01T00:00:00.000',
      };

      final result = OrganizerModel.fromJson(jsonMap);

      expect(result.id, tModel.id);
      expect(result.createdAt, tModel.createdAt);
    });
  });
}
