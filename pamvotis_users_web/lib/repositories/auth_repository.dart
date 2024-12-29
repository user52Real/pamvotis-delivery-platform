import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/secure_storage.dart';
import '../services/storage/storage_service.dart';
import '../core/network_info.dart';
import '../core/result.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  final NetworkInfo _networkInfo;
  final SecureStorage _secureStorage;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required StorageService storageService,
    required NetworkInfo networkInfo,
    required SecureStorage secureStorage,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storageService = storageService,
        _networkInfo = networkInfo,
        _secureStorage = secureStorage;

  Future<Result<UserModel>> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.failure('Login failed - no user returned');
      }

      final userData = await _getUserData(userCredential.user!.uid);
      if (userData == null) {
        return Result.failure('User data not found');
      }

      if (userData.status != "approved") {
        await _auth.signOut();
        return Result.failure('Account blocked by admin. Please contact support.');
      }

      // Cache user data
      await _storageService.saveUser(userData);

      // Store auth token if needed
      if (userCredential.user!.refreshToken != null) {
        await _secureStorage.write(
          key: 'auth_token',
          value: userCredential.user!.refreshToken!,
        );
      }

      return Result.success(userData);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthError(e));
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> logout() async {
    try {
      await _auth.signOut();
      await _secureStorage.delete(key: 'auth_token');
      // Clear stored user data
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _storageService.deleteUser(currentUser.uid);
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to logout: $e');
    }
  }

  Future<UserModel?> _getUserData(String uid) async {
    try {
      // First try to get from cache
      final cachedUser = await _storageService.getUser(uid);
      if (cachedUser != null && !await _networkInfo.isConnected) {
        return cachedUser;
      }

      // Get from Firestore
      final doc = await _firestore.collection("users").doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final user = UserModel.fromFirestore(doc.data()!);
      await _storageService.saveUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String photoUrl,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return Result.failure('Registration failed - no user created');
      }

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        photoUrl: photoUrl,
        status: 'approved',
        userCart: ['garbageValue']
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());

      // Cache user data
      await _storageService.saveUser(user);

      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthError(e));
    } catch (e) {
      return Result.failure('Registration failed: $e');
    }
  }

  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(_handleAuthError(e));
    } catch (e) {
      return Result.failure('Failed to send password reset email: $e');
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}