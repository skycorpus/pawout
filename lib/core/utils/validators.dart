class Validators {
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'Email');
    if (requiredError != null) {
      return requiredError;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, fieldName: 'Password');
    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }

  const Validators._();
}
