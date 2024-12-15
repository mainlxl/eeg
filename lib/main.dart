import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/app.dart';
import 'package:eeg/core/utils/shared_preferences_utils.dart';
import 'package:flutter/material.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesUtils.init();

  await EasyLocalization.ensureInitialized();

  EasyLocalization.logger.enableBuildModes = []; //去除多语言日志
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('zh', '')],
      path: 'locals',
      child: const MyApp(),
    ),
  );
}
