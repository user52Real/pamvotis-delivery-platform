import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../models/operation.dart';

abstract class StorageService {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String uid);
  Future<void> updateUserCart(String uid, List<String> cart);
  Future<List<String>> getUserCart(String uid);
  Future<void> deleteUser(String uid);
  Future<void> saveOperation(Operation operation);
  Future<List<Operation>> getOperations();
  Future<void> clearAll();
}