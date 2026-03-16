import 'package:flutter_test/flutter_test.dart';

/// Simple pure-function validators mirroring what the auth forms use.
/// Keeping them here avoids pulling in Flutter widget machinery.

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain an uppercase letter';
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain a number';
  }
  return null;
}

String? validateJoinCode(String? value) {
  if (value == null || value.trim().isEmpty) return 'Code is required';
  if (value.trim().length != 6) return 'Code must be 6 characters';
  if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value.trim())) {
    return 'Code must be alphanumeric';
  }
  return null;
}

void main() {
  group('Email validation', () {
    test('accepts a valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('rejects an empty email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });

    test('rejects email without @', () {
      expect(validateEmail('userexample.com'), isNotNull);
    });

    test('rejects email without domain', () {
      expect(validateEmail('user@'), isNotNull);
    });
  });

  group('Password validation', () {
    test('accepts a strong password', () {
      expect(validatePassword('SecurePass1'), isNull);
    });

    test('rejects a short password', () {
      expect(validatePassword('Ab1'), isNotNull);
    });

    test('rejects password without uppercase', () {
      expect(validatePassword('alllower1'), isNotNull);
    });

    test('rejects password without a number', () {
      expect(validatePassword('NoNumberHere'), isNotNull);
    });

    test('rejects empty password', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword(null), isNotNull);
    });
  });

  group('Join code validation', () {
    test('accepts a valid 6-char alphanumeric code', () {
      expect(validateJoinCode('AB1234'), isNull);
      expect(validateJoinCode('xyz789'), isNull);
    });

    test('rejects a code shorter than 6 characters', () {
      expect(validateJoinCode('AB12'), isNotNull);
    });

    test('rejects a code longer than 6 characters', () {
      expect(validateJoinCode('AB12345'), isNotNull);
    });

    test('rejects a code with special characters', () {
      expect(validateJoinCode('AB-123'), isNotNull);
    });

    test('rejects an empty code', () {
      expect(validateJoinCode(''), isNotNull);
      expect(validateJoinCode(null), isNotNull);
    });
  });
}
