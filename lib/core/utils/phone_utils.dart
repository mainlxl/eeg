class PhoneUtils {
  // 静态方法，用于验证手机号
  static bool isValidPhoneNumber(String phoneNumber) {
    // 定义正则表达式
    final RegExp regExp = RegExp(r'^1[3-9]\d{9}$');
    // 使用正则表达式进行匹配
    return regExp.hasMatch(phoneNumber);
  }
}
