class Validators {
  static String? validateNotEmpty(String value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  static String? validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }
}
