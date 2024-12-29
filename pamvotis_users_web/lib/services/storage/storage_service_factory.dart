import 'package:flutter/foundation.dart';
import 'package:pamvotis_users_web/services/storage/storage_service.dart';
import 'package:pamvotis_users_web/services/storage/web_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceFactory {
  static Future<StorageService> create() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return WebStorageService(prefs);
    } else {
      throw UnimplementedError('Non-web storage not implemented');
    }
  }
}