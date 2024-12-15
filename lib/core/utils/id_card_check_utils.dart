/// 身份证校验 eg:11010519491231002X
class IdCardUtils {
  // 身份证前17位数字依次乘以对应的权重因子
  static const List<int> _idCardWeight = [
    7,
    9,
    10,
    5,
    8,
    4,
    2,
    1,
    6,
    3,
    7,
    9,
    10,
    5,
    8,
    4,
    2
  ];

  // 身份证最后一位对应的校验码
  static const List<String> _idCardCheck = [
    "1",
    "0",
    "X",
    "9",
    "8",
    "7",
    "6",
    "5",
    "4",
    "3",
    "2"
  ];

  // 星座数组
  static const List<String> _constellationArr = [
    "水瓶座",
    "双鱼座",
    "白羊座",
    "金牛座",
    "双子座",
    "巨蟹座",
    "狮子座",
    "处女座",
    "天秤座",
    "天蝎座",
    "射手座",
    "魔羯座"
  ];

  // 星座对应的边缘日期
  static const List<int> _constellationEdgeDay = [
    20,
    19,
    21,
    21,
    21,
    22,
    23,
    23,
    23,
    23,
    22,
    22
  ];

  // 生肖
  static const List<String> _zodiacArr = [
    "猴",
    "鸡",
    "狗",
    "猪",
    "鼠",
    "牛",
    "虎",
    "兔",
    "龙",
    "蛇",
    "马",
    "羊"
  ];

  // 校验身份证号的有效性
  static bool idCardNumberCheck(String idCardNo) {
    // 将其转成大写有的身份证最后一位是字母
    String idCard = idCardNo.toUpperCase();

    // 15位身份证转成18位
    if (idCardNo.length == 15) {
      if (!RegExp(r"^[0-9]{17}[0-9|X]|[0-9]{15}$").hasMatch(idCardNo)) {
        // "请输入正确格式的15位身份证号码";
        return false;
      } else {
        String changed =
            "${idCardNo.substring(0, 6)}19${idCardNo.substring(6, 15)}";
        idCard = changed.toUpperCase();
      }
    }
    if (idCardNo.length != 18) {
      return false;
    }

    // 获取身份证最后一位进行验证
    String lastStr = idCard.substring(idCard.length - 1);
    String firstStr = idCard.substring(0, 17);
    bool isDigits = RegExp(r"^\d{17}").hasMatch(firstStr);
    if (!isDigits) {
      return false;
    }

    int resultSum = 0;
    for (int i = 0; i < 17; i++) {
      resultSum += int.parse(idCard[i]) * _idCardWeight[i];
    }

    int lastResult = resultSum % 11;
    if (_idCardCheck[lastResult] == lastStr) {
      return true;
    }

    return false;
  }

  // 获取年龄
  static int getAge(String idCard) {
    if (!idCardNumberCheck(idCard)) {
      return -1;
    }
    DateTime now = DateTime.now();
    String birthDate = idCard.substring(6, 14);
    String birthYear = birthDate.substring(0, 4);
    int birthYearInt = int.parse(birthYear);
    return now.year - birthYearInt;
  }

  // 根据出生日期获取星座
  String getConstellation(String idCard) {
    if (!idCardNumberCheck(idCard)) {
      return '未知';
    }
    String birthDate = idCard.substring(6, 14);
    int month = int.parse(birthDate.substring(4, 6));
    int day = int.parse(birthDate.substring(6, 8));
    if (day < _constellationEdgeDay[month - 1]) {
      month = month - 1;
    }
    if (month >= 0) {
      return _constellationArr[month];
    }
    return _constellationArr[11]; // 默认返回魔羯座
  }

  // 获取性别
  static String getSex(String idCard) {
    if (!idCardNumberCheck(idCard)) {
      return "未知";
    }
    return int.parse(idCard.substring(16, 17)) % 2 == 0 ? "女" : "男";
  }
  static String getGender(String idCard) {
    if (!idCardNumberCheck(idCard)) {
      return "未知";
    }
    return int.parse(idCard.substring(16, 17)) % 2 == 0 ? "female" : "male";
  }

  // 根据年份获取生肖
  String getZodiac(String idCard) {
    if (!idCardNumberCheck(idCard)) {
      return "未知";
    }
    // 出生日期
    String birthDate = idCard.substring(6, 14);
    String birthYear = birthDate.substring(0, 4);
    int year = int.parse(birthYear);
    return _zodiacArr[year % 12];
  }
}
