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
    return token.isNotEmpty;
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

  static int? _userId;

  static int get userId {
    if (_userId == null) {
      var userId =
          SharedPreferencesUtils.get(key: "login_user_id", defaultValue: -1);
      if (userId != -1) {
        _userId = userId;
      }
    }
    return _userId ?? -1;
  }

  static Future<bool> checkAndSaveLoginInfo(Map<String, dynamic> info) async {
    var token = info['token'] as String?;
    var userId = info['user_id'] as int? ?? -1;
    if (token != null && userId != -1 && token.isNotEmpty) {
      _userId = userId;
      _token = token;
      var tokenPut =
          await SharedPreferencesUtils.put(key: "login_token", value: token);
      var userIdPut =
          await SharedPreferencesUtils.put(key: "login_user_id", value: userId);
      return tokenPut && userIdPut;
    }
    return Future.value(false);
  }

  static Future<bool> _cleanLoginInfo() {
    _userId = null;
    _token = null;
    SharedPreferencesUtils.remove(key: "login_user_id");
    return SharedPreferencesUtils.remove(key: "login_token");
  }
}
