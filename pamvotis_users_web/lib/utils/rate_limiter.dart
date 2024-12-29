class RateLimiter {
  static final Map<String, List<DateTime>> _loginAttempts = {};
  static const int _maxAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  static bool shouldAllowLogin(String email) {
    final now = DateTime.now();
    _loginAttempts[email] ??= [];

    // Remove old attempts
    _loginAttempts[email]!.removeWhere(
            (attempt) => now.difference(attempt) > _lockoutDuration
    );

    if (_loginAttempts[email]!.length >= _maxAttempts) {
      return false;
    }

    _loginAttempts[email]!.add(now);
    return true;
  }

  static Duration? getRemainingLockoutTime(String email) {
    if (!_loginAttempts.containsKey(email)) return null;

    final oldestAttempt = _loginAttempts[email]!.first;
    final lockoutEnd = oldestAttempt.add(_lockoutDuration);
    final remaining = lockoutEnd.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }
}