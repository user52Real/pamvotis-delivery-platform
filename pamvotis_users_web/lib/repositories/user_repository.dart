import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/result.dart';
import '../models/operation.dart';
import '../models/user_model.dart';
import '../services/storage/storage_service.dart';
import '../core/network_info.dart';
import '../utils/firebase_error_handler.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StorageService _storageService;
  final NetworkInfo _networkInfo;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required StorageService storageService,
    required NetworkInfo networkInfo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storageService = storageService,
        _networkInfo = networkInfo;

  Future<Result<UserModel>> getUser(String uid) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedUser = await _storageService.getUser(uid);
        if (cachedUser != null) {
          return Result.success(cachedUser);
        }
        return Result.failure('No internet connection and no cached data available');
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return Result.failure('User not found');
      }

      final user = UserModel.fromFirestore(doc.data()!);
      await _storageService.saveUser(user);

      return Result.success(user);
    } on FirebaseException catch (e) {
      return Result.failure(FirebaseErrorHandler.handleError(e));
    } catch (e) {
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  Future<Result<void>> updateUserCart(String uid, List<String> cart) async {
    try {
      await _storageService.updateUserCart(uid, cart);

      if (!await _networkInfo.isConnected) {
        // Store pending changes
        await _storageService.saveOperation(
          Operation(
            type: 'UPDATE_CART',
            data: {'uid': uid, 'cart': cart},
          ),
        );
        return Result.success(null);
      }

      await _firestore.collection('users').doc(uid).update({
        'userCart': cart,
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update cart: $e');
    }
  }

  Future<Result<void>> syncPendingUpdates() async {
    try {
      if (!await _networkInfo.isConnected) {
        return Result.failure('No internet connection');
      }

      final operations = await _storageService.getOperations();

      for (final operation in operations) {
        if (operation.type == 'UPDATE_CART') {
          try {
            await _firestore
                .collection('users')
                .doc(operation.data['uid'])
                .update({
              'userCart': operation.data['cart'],
            });
          } catch (e) {
            print('Failed to sync update for user ${operation.data['uid']}: $e');
          }
        }
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to sync updates: $e');
    }
  }

  // Helper method to check if the user exists
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get current user data
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return Result.failure('No user is currently signed in');
      }
      return getUser(currentUser.uid);
    } catch (e) {
      return Result.failure('Failed to get current user: $e');
    }
  }

  // Method to update user profile
  Future<Result<void>> updateUserProfile({
    required String uid,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isEmpty) {
        return Result.success(null);
      }

      await _firestore.collection('users').doc(uid).update(updates);

      // Update local storage
      final currentUser = await _storageService.getUser(uid);
      if (currentUser != null) {
        final updatedUser = UserModel(
          uid: currentUser.uid,
          email: currentUser.email,
          name: name ?? currentUser.name,
          photoUrl: photoUrl ?? currentUser.photoUrl,
          status: currentUser.status,
          userCart: ['garbageValue']
        );
        await _storageService.saveUser(updatedUser);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to update profile: $e');
    }
  }
}