import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
SharedPreferences? sharedPreferences;

Future<void> initializeSharedPreferences() async {
  sharedPreferences = await SharedPreferences.getInstance();
}


class UserSession {
  static const int sessionTimeoutMinutes = 30;
  static DateTime? _lastActivity;

  static void updateLastActivity() {
    _lastActivity = DateTime.now();
  }

  static bool isSessionValid() {
    if (_lastActivity == null) return false;

    final difference = DateTime.now().difference(_lastActivity!);
    return difference.inMinutes < sessionTimeoutMinutes;
  }

  static Future<void> clearSession() async {
    await firebaseAuth.signOut();
    await sharedPreferences!.clear();
    _lastActivity = null;
  }
}