import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// shared_preferences: ^2.0.15

Future<Object?> sharedMemory(
  String key, [
  Object? value,
  bool json = false,
  bool delete = false,
]) async {
  final prefs = await SharedPreferences.getInstance();

  if (delete) {
    await prefs.remove(key);
    return true;
  }

  if (value != null) {
    if (json) {
      final encoded = jsonEncode(value);
      return await prefs.setString(key, encoded);
    }
    if (value is int) return await prefs.setInt(key, value);
    if (value is double) return await prefs.setDouble(key, value);
    if (value is bool) return await prefs.setBool(key, value);
    if (value is String) return await prefs.setString(key, value);
    if (value is List<String>) return await prefs.setStringList(key, value);
    throw Exception("Unsupported value type for SharedPreferences");
  } else {
    // Read value
    if (prefs.containsKey(key)) {
      final stored = prefs.get(key);
      if (json && stored is String) {
        try {
          return jsonDecode(stored);
        } catch (_) {
          return null;
        }
      }
      return stored;
    }
    return null;
  }
}
