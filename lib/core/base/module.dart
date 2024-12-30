import 'package:fluent_ui/fluent_ui.dart';

typedef RouteBuilder = Widget Function(
    BuildContext context, RouteSettings settings);

abstract class BaseModule {
  Map<String, RouteBuilder>? routeBuilders();

  @mustCallSuper
  void onAppCreate() {}
}
