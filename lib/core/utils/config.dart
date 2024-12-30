import 'package:flutter/foundation.dart';

const isDebug = kDebugMode;

/// 网页
bool get isWeb => kIsWeb;

bool? _isDesktop;

/// 桌面端windows linux macOS
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
