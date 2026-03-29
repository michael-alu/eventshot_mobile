import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns null for non-empty string', () {
      expect(Validators.required('hello'), isNull);
    });

    test('returns error for empty string', () {
      expect(Validators.required(''), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(Validators.required('   '), isNotNull);
    });

    test('returns error for null', () {
      expect(Validators.required(null), isNotNull);
    });

    test('uses custom message when provided', () {
      expect(Validators.required(null, 'Field is required'), 'Field is required');
    });

    test('returns default message when no custom message', () {
      expect(Validators.required(''), 'Required');
    });
  });

  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(Validators.email('user@mail.example.co.uk'), isNull);
    });

    test('returns error for empty email', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for null email', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for email missing @', () {
      expect(Validators.email('userexample.com'), isNotNull);
    });

    test('returns error for email missing domain', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('returns error for email missing TLD', () {
      expect(Validators.email('user@domain'), isNotNull);
    });

    test('uses custom message when provided', () {
      const msg = 'Bad email';
      expect(Validators.email('bad', msg), msg);
    });
  });

  group('Validators.password', () {
    test('returns null for password meeting minimum length', () {
      expect(Validators.password('secure1'), isNull);
    });

    test('returns error for empty password', () {
      expect(Validators.password(''), isNotNull);
    });

    test('returns error for null password', () {
      expect(Validators.password(null), isNotNull);
    });

    test('returns error when shorter than default minLength of 6', () {
      expect(Validators.password('ab1'), isNotNull);
    });

    test('returns null when exactly at minLength', () {
      expect(Validators.password('abcd12'), isNull);
    });

    test('respects custom minLength', () {
      expect(Validators.password('hello', minLength: 10), isNotNull);
      expect(Validators.password('helloworldX', minLength: 10), isNull);
    });

    test('uses custom message when provided', () {
      const msg = 'Too short!';
      expect(Validators.password('ab', message: msg), msg);
    });
  });
}
