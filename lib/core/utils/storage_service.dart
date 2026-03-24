import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_model.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // SharedPreferences
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }

  // Secure storage
  static Future<void> setSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  static Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // User cache for offline access
  static Future<void> cacheUser(UserModel user) async {
    await setString(AppConstants.userIdKey, user.userId);
    await setString(AppConstants.usernameKey, user.username);
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      await setString(AppConstants.userNicknameKey, user.displayName!);
    } else if (user.nickname != null && user.nickname!.isNotEmpty) {
      await setString(AppConstants.userNicknameKey, user.nickname!);
    }
    if (user.email != null) {
      await setString(AppConstants.userEmailKey, user.email!);
    }
    if (user.role != null) {
      await setString(AppConstants.userRoleKey, user.role!);
    }
  }

  static UserModel? getCachedUser() {
    final userId = getString(AppConstants.userIdKey);
    final username = getString(AppConstants.usernameKey);
    if (userId == null || username == null) return null;
    return UserModel(
      name: 'users/$userId',
      id: userId,
      username: username,
      nickname: getString(AppConstants.userNicknameKey),
      email: getString(AppConstants.userEmailKey),
      role: getString(AppConstants.userRoleKey),
    );
  }

  static Future<void> clearCachedUser() async {
    await remove(AppConstants.userIdKey);
    await remove(AppConstants.usernameKey);
    await remove(AppConstants.userNicknameKey);
    await remove(AppConstants.userEmailKey);
    await remove(AppConstants.userRoleKey);
  }

  static bool hasOfflineCredentials() {
    final token = getString(AppConstants.accessTokenKey);
    final userId = getString(AppConstants.userIdKey);
    return token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty;
  }
}
