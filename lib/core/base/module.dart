import 'package:flutter/material.dart';

typedef RouteBuilder = Widget Function(
    BuildContext context, RouteSettings settings);

abstract class BaseModule {
  Map<String, RouteBuilder>? routeBuilders();

  @mustCallSuper
  void onAppCreate() {}
}
