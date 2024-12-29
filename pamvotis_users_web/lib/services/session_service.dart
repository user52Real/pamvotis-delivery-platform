import 'dart:async';
import 'package:flutter/material.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import 'secure_storage.dart';

class SessionService {
  static const int sessionTimeoutMinutes = 30;
  static Timer? _sessionTimer;
  final SecureStorage _secureStorage;
  final Duration _sessionTimeout;

  // Updated constructor with required parameters
  SessionService({
    required SecureStorage secureStorage,
    Duration? sessionTimeout,
  }) : _secureStorage = secureStorage,
        _sessionTimeout = sessionTimeout ?? const Duration(minutes: sessionTimeoutMinutes);

  Future<bool> isSessionValid() async {
    final lastActivity = await _secureStorage.read(key: 'last_activity');
    if (lastActivity == null) return false;

    final lastActivityTime = DateTime.parse(lastActivity);
    return DateTime.now().difference(lastActivityTime) < _sessionTimeout;
  }

  Future<void> updateLastActivity() async {
    await _secureStorage.write(
      key: 'last_activity',
      value: DateTime.now().toIso8601String(),
    );
  }

  static void initializeSession(BuildContext context) {
    _resetTimer(context);

    // Listen for user activity
    Listener(
      onPointerDown: (_) => _resetTimer(context),
      onPointerMove: (_) => _resetTimer(context),
      onPointerUp: (_) => _resetTimer(context),
      child: Focus(
        onFocusChange: (hasFocus) => _resetTimer(context),
        child: const SizedBox.expand(),
      ),
    );
  }

  static void _resetTimer(BuildContext context) {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(minutes: sessionTimeoutMinutes), () {
      _handleSessionTimeout(context);
    });
  }

  static Future<void> _handleSessionTimeout(BuildContext context) async {
    await firebaseAuth.signOut();
    await sharedPreferences!.clear();

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Session Expired'),
          content: const Text('Your session has expired. Please login again.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const AuthScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      );
    }
  }

  // Added dispose method
  void dispose() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  Future<void> clearSession() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    await _secureStorage.deleteAll();
  }
}