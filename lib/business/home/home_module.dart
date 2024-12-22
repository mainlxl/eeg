import 'package:eeg/business/home/page/home_page.dart';
import 'package:eeg/core/base/module.dart';

class HomeModule extends BaseModule {
  @override
  Map<String, RouteBuilder>? routeBuilders() {
    return {
      'home': (ctx, settings) => const HomePage(),
    };
  }
}
