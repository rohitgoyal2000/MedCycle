import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAnonymousId = 'anonymous_id';
  static const String _keyRegion = 'region';
  static const String _keyLanguage = 'language';

  // Anonymous ID
  static Future<void> saveAnonymousId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAnonymousId, id);
  }

  static Future<String?> loadAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAnonymousId);
  }

  static Future<void> clearAnonymousId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAnonymousId);
  }

  // Region
  static Future<void> saveRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRegion, region);
  }

  static Future<String?> loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRegion);
  }

  // Language
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, languageCode);
  }

  static Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  // Clear all
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
