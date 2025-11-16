import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:eeg/app.dart';
import 'package:eeg/core/network/http_service.dart';
import 'package:eeg/core/utils/shared_preferences_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'core/utils/app_logger.dart';
import 'core/utils/config.dart';

_main() async {
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
          center: !isDebug,
          backgroundColor: Colors.transparent,
          skipTaskbar: false,
          titleBarStyle: TitleBarStyle.hidden,
        ), () async {
      await windowManager.setPreventClose(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }
  if (isDebug) {
    HttpService().setProxy('127.0.0.1:9090');
  }
  packageInfo = await PackageInfo.fromPlatform();
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en', 'US'), Locale('zh', 'CN')],
    path: 'locals',
    child: const MyApp(),
  ));
}

void main() async {
  runZonedGuarded<Future<void>>(_zonedMain, _onError);
}

void _onError(Object error, StackTrace stack) {
  loge('Zoned onError =====>>>>>> \n$error ${stack}',
      error: error, stackTrace: stack);
}

Future<void> _zonedMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLogger.init(filePrefix: 'app_log'); // 初始化 logger
  FlutterError.onError = (FlutterErrorDetails details) {
    loge(
      'FlutterError.onError =====>>>>>> \n${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    // 在开发模式下仍然把错误打印到控制台并显示错误界面
    FlutterError.presentError(details);
  };
  // PlatformDispatcher.instance.onError 捕获一些底层未捕获的异步错误
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    loge('PlatformDispatcher.onError =====>>>>>> \n${error} ${stack}',
        error: error, stackTrace: stack);
    // 返回 true 表示处理了该错误，避免将其上抛到默认处理
    return true;
  };
  _main();
}
