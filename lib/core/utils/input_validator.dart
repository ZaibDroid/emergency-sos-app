class InputValidator {
  static String sanitizeText(String input) {
    // Basic sanitization: remove HTML/script tags to prevent injection
    return input.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
  }

  static bool isValidPhone(String phone) {
    // Validates phone number (optional + and 10 to 14 digits)
    return RegExp(r'^\+?[0-9]{10,14}$').hasMatch(phone);
  }

  static bool isValidName(String name) {
    // Validates that the name contains only letters, spaces, and basic punctuation
    return RegExp(r"^[a-zA-Z\s\.\-']+$").hasMatch(name) && name.isNotEmpty;
  }
}
