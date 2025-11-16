import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

const isDebug = kDebugMode;

/// 网页
bool get isWeb => kIsWeb;

bool? _isDesktop;

/// 桌面端windows linux macOS
bool? _isWindows;

bool get isWindows => _isWindows ??= Platform.isWindows;
PackageInfo? packageInfo;

String get appVersion => packageInfo != null
    ? '${packageInfo?.version}+${packageInfo?.buildNumber}'
    : 'v1.0.0';

bool get isDesktop => _isDesktop ??= !isWeb &&
    [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);

bool? _isMobile;

/// 移动端ios android
bool get isMobile => _isMobile ??= !isWeb &&
    [
      TargetPlatform.android,
      TargetPlatform.iOS,
    ].contains(defaultTargetPlatform);
