import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage{
  static Future<SharedPreferences> get _instance async => _prefs ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> initPrefs() async {
    _prefs = await _instance;
    return _prefs!;
  }
  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }
  static String getString(String key, [String? defValue]) {
    return _prefs?.getString(key) ?? defValue ?? '';
  }
  static Future<bool> setInt(String key, int value) async {
    var prefs = await _instance;
    return prefs.setInt(key, value);
  }
  static int? getInt(String key, [int? defValue]) {
    return _prefs?.getInt(key) ?? defValue;
  }
}