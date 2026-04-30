import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';
import '../models/message_model.dart';

class StorageService {
  static const String _keyCurrentUser = 'current_user';
  static const String _keyRequests = 'requests';
  static const String _keyMessages = 'messages';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
  }

  User? getCurrentUser() {
    final userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  Future<void> saveRequests(List<Request> requests) async {
    final requestsJson = requests.map((r) => r.toJson()).toList();
    await _prefs.setString(_keyRequests, jsonEncode(requestsJson));
  }

  List<Request> getRequests() {
    final requestsJson = _prefs.getString(_keyRequests);
    if (requestsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(requestsJson);
    return decoded.map((json) => Request.fromJson(json)).toList();
  }

  Future<void> saveMessages(String requestId, List<Message> messages) async {
    final messagesJson = messages.map((m) => m.toJson()).toList();
    await _prefs.setString(
        '${_keyMessages}_$requestId', jsonEncode(messagesJson));
  }

  List<Message> getMessages(String requestId) {
    final messagesJson = _prefs.getString('${_keyMessages}_$requestId');
    if (messagesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(messagesJson);
    return decoded.map((json) => Message.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
