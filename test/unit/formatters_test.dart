import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventshot_mobile/core/utils/formatters.dart';

/// Helper: simulates typing a string end-to-end into a formatter.
TextEditingValue _apply(TextInputFormatter formatter, String text) {
  return formatter.formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
  );
}

void main() {
  group('CreditCardFormatter', () {
    final formatter = CreditCardFormatter();

    test('formats 16 digits into groups of 4 separated by spaces', () {
      final result = _apply(formatter, '1234567890123456');
      expect(result.text, '1234 5678 9012 3456');
    });

    test('formats partial input — 4 digits no space added yet', () {
      final result = _apply(formatter, '1234');
      expect(result.text, '1234');
    });

    test('inserts space after 4th digit', () {
      final result = _apply(formatter, '12345');
      expect(result.text, '1234 5');
    });

    test('empty input returns unchanged', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: '', selection: const TextSelection.collapsed(offset: 0)),
      );
      expect(result.text, '');
    });

    test('collapses cursor to end of formatted text', () {
      final result = _apply(formatter, '12345678');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('formats 8-digit partial card correctly', () {
      final result = _apply(formatter, '12345678');
      expect(result.text, '1234 5678');
    });
  });

  group('ExpiryDateFormatter', () {
    final formatter = ExpiryDateFormatter();

    test('formats MMYY into MM/YY', () {
      final result = _apply(formatter, '1226');
      expect(result.text, '12/26');
    });

    test('single digit — no slash added', () {
      final result = _apply(formatter, '1');
      expect(result.text, '1');
    });

    test('two digits — no slash added when at end', () {
      final result = _apply(formatter, '12');
      expect(result.text, '12');
    });

    test('three digits — slash inserted after position 2', () {
      final result = _apply(formatter, '123');
      expect(result.text, '12/3');
    });

    test('empty input returns unchanged', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: '', selection: const TextSelection.collapsed(offset: 0)),
      );
      expect(result.text, '');
    });

    test('collapses cursor to end of formatted text', () {
      final result = _apply(formatter, '1226');
      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
