import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static SharedPreferences? _prefs;

  static init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static T get<T>({required String key, required T defaultValue}) {
    if (T == String) {
      return _prefs!.getString(key) as T? ?? defaultValue;
    } else if (T == bool) {
      return _prefs!.getBool(key) as T? ?? defaultValue;
    } else if (T == int) {
      return _prefs!.getInt(key) as T? ?? defaultValue;
    } else if (T == double) {
      return _prefs!.getDouble(key) as T? ?? defaultValue;
    } else if (T == List<String>) {
      return _prefs!.getStringList(key) as T? ?? defaultValue;
    }
    return defaultValue; // 如果不支持的类型
  }

  // 存储值
  static Future<bool> put<T>({required String key, required T value}) async {
    if (T == String) {
      return _prefs!.setString(key, value as String);
    } else if (T == int) {
      return _prefs!.setInt(key, value as int);
    } else if (T == bool) {
      return _prefs!.setBool(key, value as bool);
    } else if (T == double) {
      return _prefs!.setDouble(key, value as double);
    } else if (T == List<String>) {
      return _prefs!.setStringList(key, value as List<String>);
    }
    return false; // 如果不支持的类型
  }

  // 删除某个键
  static Future<bool> remove({required String key}) async {
    return _prefs!.remove(key);
  }

  // 检查某个键是否存在
  static bool containsKey(String key) {
    return _prefs!.containsKey(key);
  }
}

extension SharedPreferencesBoolExtensions on bool {
  Future<bool> putSP({required String key}) {
    return SharedPreferencesUtils._prefs!.setBool(key, this);
  }
}

extension SharedPreferencesStringExtensions on String {
  Future<bool> putSP({required String key}) {
    return SharedPreferencesUtils._prefs!.setString(key, this);
  }

  T? getSPValue<T>({required T defaultValue}) {
    return SharedPreferencesUtils.get(key: this, defaultValue: defaultValue);
  }

  Future<bool> putSPValue<T>({required T value}) {
    return SharedPreferencesUtils.put(key: this, value: value);
  }
}

extension SharedPreferencesIntExtensions on int {
  Future<bool> putSP({required String key}) {
    return SharedPreferencesUtils._prefs!.setInt(key, this);
  }
}

extension SharedPreferencesDoubleExtensions on double {
  Future<bool> putSP({required String key}) {
    return SharedPreferencesUtils._prefs!.setDouble(key, this);
  }
}

extension SharedPreferencesStringListExtensions on List<String> {
  Future<bool> putSP({required String key}) {
    return SharedPreferencesUtils._prefs!.setStringList(key, this);
  }
}
