import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/operation.dart';
import '../../models/user_model.dart';
import 'storage_service.dart';

class WebStorageService implements StorageService {
  final SharedPreferences _prefs;

  WebStorageService(this._prefs);

  @override
  Future<void> saveUser(UserModel user) async {
    final userData = {
      'uid': user.uid,
      'email': user.email,
      'name': user.name,
      'photoUrl': user.photoUrl,
      'status': user.status,
      'userCart': user.userCart,
    };
    await _prefs.setString('user_${user.uid}', jsonEncode(userData));
  }

  @override
  Future<UserModel?> getUser(String uid) async {
    final data = _prefs.getString('user_$uid');
    if (data == null) return null;

    final Map<String, dynamic> userData = jsonDecode(data);
    return UserModel(
      uid: userData['uid'] ?? '',
      email: userData['email'] ?? '',
      name: userData['name'] ?? '',
      photoUrl: userData['photoUrl'] ?? '',
      status: userData['status'] ?? 'pending',
      userCart: List<String>.from(userData['userCart'] ?? ['garbageValue']),
    );
  }

  @override
  Future<void> updateUserCart(String uid, List<String> cart) async {
    final data = _prefs.getString('user_$uid');
    if (data != null) {
      final Map<String, dynamic> userData = jsonDecode(data);
      userData['userCart'] = cart;
      await _prefs.setString('user_$uid', jsonEncode(userData));
    }
  }

  @override
  Future<List<String>> getUserCart(String uid) async {
    final data = _prefs.getString('user_$uid');
    if (data != null) {
      final Map<String, dynamic> userData = jsonDecode(data);
      return List<String>.from(userData['userCart'] ?? ['garbageValue']);
    }
    return ['garbageValue'];
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _prefs.remove('user_$uid');
  }

  @override
  Future<void> saveOperation(Operation operation) async {
    final operations = await getOperations();
    operations.add(operation);

    final List<Map<String, dynamic>> operationsData = operations
        .map((op) => {
      'type': op.type,
      'timestampInMs': op.timestampInMs,
      'dataJson': op.dataJson,
    })
        .toList();

    await _prefs.setString('operations', jsonEncode(operationsData));
  }

  @override
  Future<List<Operation>> getOperations() async {
    final data = _prefs.getString('operations');
    if (data == null) return [];

    final List<dynamic> operationsData = jsonDecode(data);
    return operationsData
        .map((op) => Operation(
      type: op['type'],
      data: jsonDecode(op['dataJson']),
    ))
        .toList();
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}