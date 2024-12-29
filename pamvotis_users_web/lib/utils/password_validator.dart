class PasswordValidator {
  static bool hasMinLength(String password) => password.length >= 8;
  static bool hasUppercase(String password) => password.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String password) => password.contains(RegExp(r'[a-z]'));
  static bool hasDigits(String password) => password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialCharacters(String password) =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  static String? validate(String password) {
    if (!hasMinLength(password)) {
      return 'Password must be at least 8 characters long';
    }
    if (!hasUppercase(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigits(password)) {
      return 'Password must contain at least one number';
    }
    if (!hasSpecialCharacters(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}