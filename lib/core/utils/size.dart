import 'dart:ui';

import 'package:flutter/material.dart';

class SizeUtils {
  static MediaQueryData _mediaQueryData =
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first);

  static final List<VoidCallback> _metricsChangedListeners = [];

  static init() {
    var base = PlatformDispatcher.instance.onMetricsChanged;
    PlatformDispatcher.instance.onMetricsChanged = () {
      _mediaQueryData =
          MediaQueryData.fromView(PlatformDispatcher.instance.views.first);
      if (base != null) {
        base();
      }
      for (final listener in _metricsChangedListeners) {
        listener();
      }
    };
  }

  static void addMetricsChangedListener(VoidCallback listener) {
    _metricsChangedListeners.add(listener);
  }

  static void removeMetricsChangedListener(VoidCallback listener) {
    _metricsChangedListeners.remove(listener);
  }

  static double get screenWidth => _mediaQueryData.size.width;

  static Size get screenSize => _mediaQueryData.size;

  static double get screenHeight => _mediaQueryData.size.height;

  static double get paddingTop => _mediaQueryData.padding.top;

  // 获取状态栏高度像素
  static EdgeInsets get padding => _mediaQueryData.padding;

  static double get paddingTopPixel =>
      _mediaQueryData.padding.top * _mediaQueryData.devicePixelRatio;

  static double pixelToFlutterDp(double pixel) =>
      pixel / _mediaQueryData.devicePixelRatio;
}
