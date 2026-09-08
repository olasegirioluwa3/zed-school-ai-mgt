import 'dart:convert';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _schoolKey = 'selected_school';
  static const String _userRoleKey = 'user_role';
  static const String _userKey = 'user_data';
  static const String _selectedSchoolIdKey = 'selected_school_id';

  static Future<void> saveSchool(Map<String, dynamic> schoolData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schoolKey, jsonEncode(schoolData));
  }

  static Future<Map<String, dynamic>?> getSchool() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolString = prefs.getString(_schoolKey);
    if (schoolString == null) return null;
    try {
      return jsonDecode(schoolString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> getSelectedSchoolId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedSchoolIdKey);
  }

  static Future<void> saveSelectedSchoolId(String schoolId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSchoolIdKey, schoolId);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(userString);
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_schoolKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userKey);
    await prefs.remove(_selectedSchoolIdKey);
  }
}
