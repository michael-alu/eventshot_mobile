class Validators {
  static String? required(String? value, [String message = 'Required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, [String message = 'Enter a valid email address']) {
    final req = required(value);
    if (req != null) return req;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return message;
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6, String? message}) {
    final req = required(value);
    if (req != null) return req;

    if (value!.length < minLength) {
      return message ?? 'Password must be at least $minLength characters';
    }
    return null;
  }
}
