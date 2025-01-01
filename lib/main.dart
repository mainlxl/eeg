import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/app.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/shared_preferences_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'core/utils/config.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesUtils.init();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = []; //去除多语言日志
  if (isMobile) {
    await SystemTheme.accentColor.load();
    //状态栏透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景色透明
      statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色（根据页面背景颜色调整）
    ));
  } else if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow(
        const WindowOptions(
          minimumSize: Size(1280, 720),
          center: true,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
        ), () async {
      await windowManager.setPreventClose(true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
  if (isDebug) {
    HttpService().setProxy('127.0.0.1:8888');
  }
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],
    path: 'locals',
    child: const MyApp(),
  ));
}
