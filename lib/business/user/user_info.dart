import 'package:eeg/app.dart';
import 'package:eeg/core/utils/shared_preferences_utils.dart';
import 'package:fluent_ui/fluent_ui.dart';

class UserInfo {
  static void cleanTaskAndPushLoginPage() async {
    // 清除所有之前的页面
    if (await _cleanLoginInfo()) {
      getAppNavigatorState?.pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
    }
  }

  static bool isLogin() {
    return SharedPreferencesUtils.get(key: "login_token", defaultValue: "")
        .isNotEmpty;
  }

  static String? _token;

  static String get token {
    if (_token == null) {
      var readToken =
          SharedPreferencesUtils.get(key: "login_token", defaultValue: "");
      if (readToken.isNotEmpty) {
        _token = readToken;
      }
    }
    return _token ?? '';
  }

  static String? _userId;

  static String get userId {
    if (_userId == null) {
      var readToken =
          SharedPreferencesUtils.get(key: "login_user_id", defaultValue: -1);
      if (readToken != -1) {
        _userId = readToken.toString();
      }
    }
    return _userId ?? '';
  }

  static Future<bool> checkAndSaveLoginInfo(Map<String, dynamic> info) async {
    var token = info['token'] as String?;
    var user = info['user'] as Map<String, dynamic>?;
    var userId = (user?['id'] as int?) ?? -1;
    if (token != null && user != null && userId != -1 && token.isNotEmpty) {
      var tokenPut =
          await SharedPreferencesUtils.put(key: "login_token", value: token);
      var userIdPut =
          await SharedPreferencesUtils.put(key: "login_user_id", value: userId);
      return tokenPut && userIdPut;
    }
    return Future.value(false);
  }

  static Future<bool> _cleanLoginInfo() {
    return SharedPreferencesUtils.remove(key: "login_token");
  }
}
