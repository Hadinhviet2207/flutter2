import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserService {
  static const String _anonymousUserIdKey = 'anonymous_user_id';

  Future<String> getOrCreateAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? anonymousUserId = prefs.getString(_anonymousUserIdKey);
    if (anonymousUserId == null) {
      anonymousUserId = const Uuid().v4();
      await prefs.setString(_anonymousUserIdKey, anonymousUserId);
    }
    return anonymousUserId;
  }

  Future<void> clearAnonymousUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_anonymousUserIdKey);
  }
}
