import 'package:fluent_ui/fluent_ui.dart';

class RouterUtils {
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String pageName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, pageName, arguments: arguments);
  }

  static Future<T?> push<T extends Object?>(
      BuildContext context, WidgetBuilder builder) {
    return Navigator.push(context, FluentPageRoute(builder: builder));
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      BuildContext context, Widget pageWidget,
      {TO? result}) {
    return Navigator.pushReplacement(
        context, FluentPageRoute(builder: (context) => pageWidget),
        result: result);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      BuildContext context, String pageName,
      {TO? result, Object? arguments}) {
    return Navigator.pushReplacementNamed(context, pageName,
        result: result, arguments: arguments);
  }

  static void popPage<T extends Object?>(BuildContext context, [T? result]) {
    return Navigator.pop(context, result);
  }
}

extension AppRouterStateExtensions on State {
  void popPage<T extends Object?>([T? result]) {
    return Navigator.pop(this.context, result);
  }
}

extension AppRouterBuildContextExtensions on BuildContext {
  void popPage<T extends Object?>([T? result]) {
    return RouterUtils.popPage(this, result);
  }

  Future<T?> pushNamed<T extends Object?>(
    String pageName, {
    Object? arguments,
  }) {
    return RouterUtils.pushNamed<T>(this, pageName, arguments: arguments);
  }

  Future<T?> push<T extends Object?>(
      BuildContext context, WidgetBuilder builder) {
    return RouterUtils.push<T>(this, builder);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
      String pageName,
      {TO? result,
      Object? arguments}) {
    return RouterUtils.pushReplacementNamed(this, pageName,
        result: result, arguments: arguments);
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      Widget pageWidget,
      {TO? result}) {
    return RouterUtils.pushReplacement(this, pageWidget, result: result);
  }
}
