import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password provided';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'operation-not-allowed':
          return 'Operation not allowed';
        case 'weak-password':
          return 'The password provided is too weak';
        case 'user-disabled':
          return 'This user account has been disabled';
        default:
          return error.message ?? 'Authentication error occurred';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to perform this action';
        case 'unavailable':
          return 'The service is currently unavailable';
        case 'not-found':
          return 'The requested resource was not found';
        case 'already-exists':
          return 'The resource already exists';
        default:
          return error.message ?? 'A Firebase error occurred';
      }
    }

    return error.toString();
  }
}