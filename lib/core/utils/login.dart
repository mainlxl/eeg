import 'package:eeg/core/utils/shared_preferences_utils.dart';

class LoginUtills {
  static bool isLogin() {
    return SharedPreferencesUtils.get("isLogin") ?? false;
  }
}
