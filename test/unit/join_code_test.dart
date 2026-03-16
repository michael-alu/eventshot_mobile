import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/features/events/data/models/event_model.dart';

void main() {
  group('EventModel.generateJoinCode', () {
    test('produces a 6-character string', () {
      final code = EventModel.generateJoinCode();
      expect(code.length, 6);
    });

    test('contains only alphanumeric characters', () {
      for (var i = 0; i < 20; i++) {
        final code = EventModel.generateJoinCode();
        expect(
          RegExp(r'^[A-Z0-9]+$').hasMatch(code),
          isTrue,
          reason: 'code "$code" contains invalid characters',
        );
      }
    });

    test('generates different codes across calls', () {
      final codes = List.generate(10, (_) => EventModel.generateJoinCode());
      // At least 2 distinct codes among 10 attempts (probability of collision is negligible)
      expect(codes.toSet().length, greaterThan(1));
    });
  });
}
