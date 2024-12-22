import 'package:flutter/foundation.dart';

const isDebug = kDebugMode;

bool get isWeb => kIsWeb;
bool? _isDesktop;

bool get isDesktop => _isDesktop ??= !isWeb &&
    [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);
