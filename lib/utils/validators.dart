class Validators {
  const Validators._();

  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? fullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Enter your full name';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? postalCode(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 4 || text.length > 10) return 'Enter a valid postal code';
    return null;
  }

  static String? message(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 10) return 'Please write at least 10 characters';
    if (text.length > 1000) return 'Message is too long';
    return null;
  }
}
