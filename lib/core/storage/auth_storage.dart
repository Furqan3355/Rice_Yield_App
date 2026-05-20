import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for auth session flag.
class AuthStorage {
  AuthStorage._();

  static const String isLoggedInKey = 'isLoggedIn';

  static Future<bool> readIsLoggedIn(SharedPreferences prefs) async {
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(
    SharedPreferences prefs, {
    required bool value,
  }) async {
    await prefs.setBool(isLoggedInKey, value);
  }
}
